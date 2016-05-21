module Minke
  module Docker
    ##
    # ServiceDiscovery allows you to look up the publicly accessible address and port for a server
    class ServiceDiscovery
      def initialize config
        reader = Minke::Config::Reader.new
        @config = reader.read config
      end

      ##
      # Will attempt to locate the public details for a running container given
      # its name and private port
      # Parameters:
      # - container_name: the name of the running container
      # - private_port: the private port which you wish to retrieve an address for
      # - task: :run, :cucumber search either the run or cucumber section of the config
      def public_address_for container_name, private_port, task
        compose = Minke::Docker::DockerCompose.new @config.compose_file_for(task), Minke::Docker::SystemRunner.new
        docker_runner = Minke::Docker::DockerRunner.new

        public_address = compose.public_address container_name, private_port

        ip = docker_runner.get_docker_ip_address
        if  ip != "127.0.0.1" && ip != "0.0.0.0" && ip != nil
          public_address.gsub!('0.0.0.0', ip)
        end

        public_address
      end
    end
  end
end
