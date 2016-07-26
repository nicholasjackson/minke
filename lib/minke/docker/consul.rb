module Minke
  module Docker
    class Consul
      def initialize health_check, service_discovery, consul_loader, docker_runner, network, project_name
        @health_check = health_check
        @service_discovery = service_discovery
        @consul_loader = consul_loader
        @docker_runner = docker_runner
        @network = network
        @project_name = project_name
      end

      ##
      # start_and_load_data config
      def start_and_load_data consul_config
        start
        wait_for_startup consul_config.url
        load_data consul_config.url, consul_config.config_file
      end

      ##
      # stop consul
      def stop
        @docker_runner.stop_container @container
        @docker_runner.delete_container @container
      end

      private
      def start
        @docker_runner.pull_image 'progrium/consul:latest' unless @docker_runner.find_image 'progrium/consul:latest'
        @container, success = @docker_runner.create_and_run_container(
          {
            :image   => 'progrium/consul',
            :network => @network,
            :command => '-server -bootstrap -ui-dir /ui',
            :name    => "/#{@project_name}_consul_1",
            :deamon  => true
          }
        )
      end

      def wait_for_startup url
        server = @service_discovery.build_address(url)
        @health_check.wait_for_HTTPOK "#{server}/v1/status/leader"
      end

      ##
      # Loads consul data into the given server
      def load_data url, config_file
        server = @service_discovery.build_address(url)
        @consul_loader.load_config config_file, server
      end
    end
  end
end
