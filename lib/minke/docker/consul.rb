module Minke
  module Docker
    class Consul
      def initialize health_check, service_discovery, consul_loader, docker_runner, network
        @health_check = health_check
        @service_discovery = service_discovery
        @consul_loader = consul_loader
        @docker_runner = docker_runner
        @network = network
      end

      ##
      # start_and_load_data config
      def start_and_load_data consul_config
        start
        load_data consul_config.url, consul_config.config_file
        wait_for_startup consul_config.url
      end

      ##
      # stop consul
      def stop
        @docker_runner.stop_container @container
        @docker_runner.delete_container @container
      end

      private
      def start
        @container = @docker_runner.create_and_run_container(
          {:image   => 'progrium/consul', :network => @network})
      end
      
      def wait_for_startup url
        server = @service_discovery.build_address(url)
        @health_check.wait_for_HTTPOK "#{server}/v1/status/leader"
      end

      ##
      # Loads consul data into the given server
      def load_data url, config_file
        puts config_file

        server = @service_discovery.build_address(url)
        @consul_loader.load_config config_file, server
      end
    end
  end
end