module Minke
  module Docker
    class DockerRunner
      ##
      # returns the ip address that docker is running on
      def get_docker_ip_address
        # first try to get the ip from docker-ip env
        if !ENV['DOCKER_IP'].to_s.empty?
          return ENV['DOCKER_IP']
        end

        if !ENV['DOCKER_HOST'].to_s.empty?
      		# dockerhost set
      		host = ENV['DOCKER_HOST'].dup
      		host.gsub!(/tcp:\/\//, '')
      		host.gsub!(/:\d+/,'')

      		return host
        else
          return '127.0.0.1'
      	end
      end

      ##
      # find_image finds a docker image in the local registry
      # Returns
      #
      # Docker::Image
      def find_image image_name
      	found = nil
      	::Docker::Image.all.each do | image |
      		found = image if image.info["RepoTags"].include? image_name
      	end

      	return found
      end

      ##
      # pull_image pulls a new copy of the given image from the registry
      def pull_image image_name
      	puts "Pulling Image: #{image_name}"
        ::Docker::Image.create('fromImage' => image_name)
      end

      ##
      # running_images returns a list of running containers
      # Returns
      #
      # Array of Docker::Image
      def running_containers
        containers = ::Docker::Container.all(all: true, filters: { status: ["running"] }.to_json)
        return containers
      end

      ##
      # create_and_run_container starts a conatainer of the given image name and executes a command
      #
      # Returns:
      # - Docker::Container
      # - sucess (true if command succeded without error)
      def create_and_run_container image, volumes, environment, working_directory, cmd
      	# update the timeout for the Excon Http Client
      	# set the chunk size to enable streaming of log files
        #puts working_directory
        puts volumes
        #puts environment

        ::Docker.options = {:chunk_size => 1, :read_timeout => 3600}
        container = ::Docker::Container.create(
      		'Image' => image,
      		'Cmd' => cmd,
      		"Binds" => volumes,
      		"Env" => environment,
      		'WorkingDir' => working_directory)

        success = true

        thread = Thread.new do
          container.attach(:stream => true, :stdin => nil, :stdout => true, :stderr => true, :logs => false, :tty => false) do
             |stream, chunk|
              stream.to_s == 'stdout' ? color = :green : color  = :red
              puts "#{chunk.strip}".colorize(color)

              if stream.to_s == "stderr"
                success = false
              else
                success = true
              end
          end
        end

        container.start
        thread.join

      	return container, success
      end

      ##
      # build_image creates a new image from the given Dockerfile and name
      def build_image dockerfile_dir, name
        puts dockerfile_dir
        puts name
        ::Docker.options = {:read_timeout => 6200}
        begin
          ::Docker::Image.build_from_dir(dockerfile_dir, {:t => name}) do |v|
            data = /{"stream.*:"(.*)".*/.match(v)
            data = data[1].encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''}) unless data == nil || data.length < 1
            $stdout.puts data unless data == nil
          end
        rescue => e
          puts e
          message = /.*{"message":"(.*?)"}/.match(e.to_s)
          puts "Error: #{message[1]}" unless message == nil || message.length < 1
        end
      end

      def delete_container container
        if container != nil
          begin
            container.delete()
          rescue => e
            puts "Error: Unable to delete container"
          end
        end
      end

      def login_registry url, user, password, email
        if docker_version.start_with? '1.11'
          # email is removed for login in docker 1.11
          system("docker login -u #{user} -p #{password} #{url}")
        else
          system("docker login -u #{user} -p #{password} -e #{email} #{url}")
        end
        $?.exitstatus
      end

      def tag_image image_name, tag
        image =  self.find_image "#{image_name}:latest"
      	image.tag('repo' => tag, 'force' => true) unless image.info["RepoTags"].include? "#{tag}:latest"
      end

      def push_image image_name
      	system("docker push #{image_name}:latest")
        $?.exitstatus ==  0
      end

      def docker_version
        ::Docker.version['Version']
      end
    end
  end
end
