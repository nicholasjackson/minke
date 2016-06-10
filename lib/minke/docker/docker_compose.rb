module Minke
  module Docker
    class DockerComposeFactory
      def initialize system_runner
        @system_runner = system_runner
      end

      def create compose_file
        Minke::Docker::DockerCompose.new compose_file, @system_runner
      end
    end

    class DockerCompose
      @compose_file = nil

      def initialize compose_file, system_runner
        @compose_file = compose_file
        @system_runner = system_runner
      end

      ##
      # start the containers in a stack defined by the docker compose file
      def up
        unless ENV['DOCKER_NETWORK'].to_s.empty?
          directory = create_compose_network_file

          @system_runner.execute "docker-compose -f #{@compose_file} -f #{directory + '/docker-compose.yml'} up -d"
          @system_runner.remove_entry_secure directory
        else
          @system_runner.execute "docker-compose -f #{@compose_file} up -d"
        end

        sleep 2
      end

      ##
      # stop the containers in a stack and removes them as defined by the docker compose file
      def down
        unless ENV['DOCKER_NETWORK'].to_s.empty?
          directory = create_compose_network_file

          @system_runner.execute "docker-compose -f #{@compose_file} -f #{directory + '/docker-compose.yml'} down"
          @system_runner.remove_entry_secure directory
        else
          @system_runner.execute "docker-compose -f #{@compose_file} down -d"
        end
      end

      ##
      # remove the containers started in a stack defined by the docker compose file
      def rm
        @system_runner.execute "echo y | docker-compose -f #{@compose_file} rm -v" unless ::Docker.info["Driver"] == "btrfs"
      end

      ##
      # stream the logs for the current running stack
      def logs
        @system_runner.execute "docker-compose -f #{@compose_file} logs -f"
      end

      ##
      # return the local address and port of a containers private port
      def public_address container, private_port
        @system_runner.execute_and_return "docker-compose -f #{@compose_file} port #{container} #{private_port}"
      end

      def create_compose_network_file
        content = { 'version' => '2'.to_s, 'networks' => {'default' => { 'external' => { 'name' => ENV['DOCKER_NETWORK'] } } } }

        directory = @system_runner.mktmpdir

        temp_file = directory + '/docker-compose.yml'
        @system_runner.write_file temp_file, YAML.dump(content)

        directory
      end
    end
  end
end
