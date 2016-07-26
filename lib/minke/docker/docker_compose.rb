module Minke
  module Docker
    class DockerComposeFactory
      def initialize system_runner, project_name, docker_network = nil
        @project_name = project_name
        @system_runner = system_runner
        @docker_network = docker_network
      end

      def create compose_file
        Minke::Docker::DockerCompose.new compose_file, @system_runner, @project_name, @docker_network
      end
    end

    class DockerCompose
      @compose_file = nil

      def initialize compose_file, system_runner, project_name, docker_network = nil
        @project_name = project_name
        @compose_file = compose_file
        @system_runner = system_runner
        @docker_network = docker_network ||= 'bridge'
      end

      ##
      # start the containers in a stack defined by the docker compose file
      def up
        execute_command "up -d"
        sleep 2
      end

      ##
      # stop the containers in a stack and removes them as defined by the docker compose file
      def down
        execute_command "down -v"
      end

      ##
      # remove the containers started in a stack defined by the docker compose file
      def rm
        execute_command 'rm -v' unless ::Docker.info["Driver"] == "btrfs"
      end

      ##
      # stream the logs for the current running stack
      def logs
        execute_command 'logs -f'
      end

      def execute_command command
        hash = create_compose

        unless @docker_network == nil
          hash.merge!(create_compose_network)
        end

        directory = @system_runner.mktmpdir
        temp_file = directory + '/docker-compose.yml'
        @system_runner.write_file temp_file, YAML.dump(hash)

        ex = "docker-compose -f #{temp_file} -p #{@project_name} #{command}"

        @system_runner.execute ex
        @system_runner.remove_entry_secure directory
      end

      def create_compose_network
        { 'networks' => {'default' => { 'external' => { 'name' => @docker_network } } } }
      end

      def create_compose
        existing = YAML.load(File.read(@compose_file))
        services = {}

        existing['services'].keys.each do |key|
          newservice = existing['services'][key].merge({'external_links' => ["#{@project_name}_consul_1:consul"]})
          services[key] = newservice
        end

        compose = { 'version' => 2.to_s, 'services' => services }

        compose
      end

    end
  end
end
