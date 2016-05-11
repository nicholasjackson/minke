module Minke
  module Docker
    class DockerRunner
      ##
      # returns the ip address that docker is running on
      def get_docker_ip_address
        if ENV['DOCKER_IP'] == nil
          if ENV['DOCKER_HOST']
        		# dockerhost set
        		host = ENV['DOCKER_HOST'].dup
        		host.gsub!(/tcp:\/\//, '')
        		host.gsub!(/:\d+/,'')

        		return host
          else
            return '127.0.0.1'
        	end
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
      	puts `docker pull #{image_name}`
      end

      ##
      # create_and_run_container starts a conatainer of the given image name and executes a command
      #
      # Returns:
      # - Docker::Container
      # - sucess (true if command succeded without error)
      def create_and_run_container image, volumes, environment, working_directory, cmd
        puts working_directory
        puts volumes
        puts cmd
        puts image
      	# update the timeout for the Excon Http Client
      	# set the chunk size to enable streaming of log files
        ::Docker.options = {:chunk_size => 1, :read_timeout => 3600}
        container = ::Docker::Container.create(
      		'Image' => image,
      		'Cmd' => cmd,
      		"Binds" => volumes,
      		"Env" => environment,
      		'WorkingDir' => working_directory)

        success = false

        thread = Thread.new {
          container.attach { |stream, chunk|
            puts "#{chunk}"

            if stream.to_s == "stdout"
              success = true
            else
              success = false
            end
          }
        }
        container.start
        thread.join

      	return container, success
      end

      ##
      # build_image creates a new image from the given Dockerfile and name
      def build_image dockerfile_dir, name
        Docker.options = {:read_timeout => 6200}
        Docker::Image.build_from_dir dockerfile_dir, {:t => name}
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
        system("docker login -u #{user} -p #{password} -e #{email} #{url}")
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
    end
  end
end
