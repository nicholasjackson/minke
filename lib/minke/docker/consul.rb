module Minke
  module Docker
    class Consul
      ##
      # Loads consul data into the given server
      def load_consul_data server, config_file
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        puts config_file
        loader.load_config config_file, server
      end

      ##
      # start_consul_and_load_data config
      def start_consul_and_load_data
        #start consul
        #wait_for_HTTPOK "#{server}/v1/status/leader", 0, 1
        load_consul_data steps.consul_loader
      end

      ##
      # load consul config
      def load_consul_data config
        @helper.load_consul_data build_address(config.url), config.config_file
      end

      ##
      # stop consul
      def stop_consul

      end
    end
  end
end