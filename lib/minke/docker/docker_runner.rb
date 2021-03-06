module Minke
  module Docker
    class DockerRunner
      def initialize logger, network = nil, project = nil
        @network = network ||= 'bridge'
        @logger = logger
        @project = project
      end

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
      		found = image if image.info["RepoTags"] != nil && image.info["RepoTags"].include?(image_name)
      	end

      	return found
      end

      ##
      # pull_image pulls a new copy of the given image from the registry
      def pull_image image_name
        ::Docker.options = {:chunk_size => 1, :read_timeout => 3600}
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
      def create_and_run_container args
      	# update the timeout for the Excon Http Client
      	# set the chunk size to enable streaming of log files
        ::Docker.options = {:chunk_size => 1, :read_timeout => 3600}
        container = ::Docker::Container.create(
      		'Image'           => args[:image],
      		'Cmd'             => args[:command],
      		"Binds"           => args[:volumes],
      		"Env"             => args[:environment],
          'NetworkMode'     => @network,
      		'WorkingDir'      => args[:working_directory],
          'name'            => args[:name],
          'PublishAllPorts' => true
        )

        output = ''

        unless args[:deamon] == true
          thread = Thread.new do
            container.attach(:stream => true, :stdin => nil, :stdout => true, :stderr => true, :logs => false, :tty => false) do
              |stream, chunk|
                if chunk.index('[ERROR]') != nil # deal with hidden characters
                  @logger.error chunk.gsub(/\[.*\]/,'')
                else
                  output += chunk.gsub(/\[.*\]/,'') if output == ''
                  output += chunk.gsub(/\[.*\]/,'').prepend("       ") unless output == ''
                  @logger.debug chunk.gsub(/\[.*\]/,'')
                end
            end
          end
        end

        container.start
        thread.join unless args[:deamon] == true

        success = (container.json['State']['ExitCode'] == 0) ? true: false 
        @logger.error(output) unless success 

      	return container, success
      end
      
      ##
      # create_and_run_blocking_container starts a conatainer of the given image name and executes a command, 
      # this method blocks until the container exits
      #
      # Returns:
      # - Docker::Container
      # - sucess (true if command succeded without error)
      def create_and_run_blocking_container args
        host_config = get_port_bindings args
        host_config['NetworkMode'] = @network
        host_config['Binds'] = args[:volumes]

        if args[:links] != nil 
          network = {'EndpointsConfig' => {@network =>
            {'Links' => args[:links].map {|l| "#{@project}_#{l}_1:#{l}"}}
          }}
        end

        exposed_ports = get_exposed_ports args

      	# update the timeout for the Excon Http Client
      	# set the chunk size to enable streaming of log files
        #::Docker.options = {:chunk_size => 1, :read_timeout => 3600}
        container = ::Docker::Container.create(
      		'Image'            => args[:image],
      		'Cmd'              => args[:command],
      		"Binds"            => args[:volumes],
      		"Env"              => args[:environment],
      		'WorkingDir'       => args[:working_directory],
          'name'             => args[:name],
          'NetworkMode'      => @network,
          "OpenStdin"        => true,
          "Tty"              => true,
          'PublishAllPorts'  => true,
          'ExposedPorts'     => exposed_ports,
          'HostConfig'       => host_config,
          'NetworkingConfig' => network
        )

        container.start
      
        success = (container.json['State']['ExitCode'] == 0) ? true: false 
        @logger.error("Unable to start docker container") unless success 

        STDIN.raw do |stdin|
          container.attach(stdin: stdin, tty: true) do |chunk|
            print chunk
          end
        end

        return container, success
      end

      ##
      # build_image creates a new image from the given Dockerfile and name
      def build_image dockerfile_dir, name
        ::Docker.options = {:read_timeout => 6200}
        begin
          ::Docker::Image.build_from_dir(dockerfile_dir, {:t => name}) do |v|
            data = /{"stream.*:"(.*)".*/.match(v)
            data = data[1].encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''}).chomp('/n') unless data == nil || data.length < 1
            @logger.info data unless data == nil
          end
        rescue => e
          message = e.message
          @logger.error "Error: #{message}" unless message == nil || message.length < 1
        end
      end

      def stop_container container
        container.stop()
      end

      def delete_container container
        if container != nil
          begin
            container.delete()
          rescue => e
            @logger.error "Error: Unable to delete container: #{e}"
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

      def get_port_bindings args
        host_config = {}
        if args[:ports] != nil 
          port_bindings = {}
          args[:ports].each do |p|
            hostDest = p.split(":")
            if hostDest[0] == ""
              port_bindings[hostDest[1] + "/tcp"] = [{'HostPort' => "#{rand(40000..50000)}", 'HostIp' => "0.0.0.0"}]
            else 
              port_bindings[hostDest[1] + "/tcp"] = [{'HostPort' => hostDest[0], 'HostIp' => "0.0.0.0"}]
            end
          end
          host_config = {'PortBindings' => port_bindings }
        end

        return host_config
      end

      def get_exposed_ports args
        port_bindings = {}
        if args[:ports] != nil 
          args[:ports].each do |p|
            hostDest = p.split(":")
            port_bindings[hostDest[1] + "/tcp"] = {}
          end
        end

        return port_bindings
      end

    end
  end
end
