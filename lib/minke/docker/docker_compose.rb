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

      def up
        @system_runner.execute "docker-compose -f #{@compose_file} up -d"
        sleep 2
      end

      def stop
        @system_runner.execute "docker-compose -f #{@compose_file} stop"
      end

      def rm
        @system_runner.execute "echo y | docker-compose -f #{@compose_file} rm -v" unless ::Docker.info["Driver"] == "btrfs"
      end

      def logs
        @system_runner.execute "docker-compose -f #{@compose_file} logs -f"
      end

      ##
      # returns and array of details containing the public ports and addresses of containers
      # started with docker compose.
      # [{:name => 'statsd', :address => '0.0.0.0', :public_port => '3000', :private_port => '8080'}]
      def get_public_ports
        return @ports unless @ports == nil

        @ports = []

        file = YAML.load(File.read(@compose_file))

        file['services'].each do |e|
          if e[1]['ports'] != nil
            e[1]['ports'].each do |p|
              address = public_address e[0], p

              @ports.push({
                :name => e[0],
                :private_port => (parse_private p),
                :public_port => address.split(':').last,
                :address => address.split(':').first
              }) #
            end
          end
        end

        return @ports
      end

      def get_port_by_name container_name, private_port
        get_public_ports.select { |x| x[:name] == container_name && x[:private_port] == private_port }.first
      end

      private
      def parse_private ports
        ports.split(':').last
      end
      ##
      # return the local address and port of a containers private port
      def public_address container, private_port
        @system_runner.execute "docker-compose -f #{@compose_file} port #{container} #{private_port}"
      end
    end
  end
end
