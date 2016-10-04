module Minke
  module Docker
    class Network
      def initialize network_name, shell_runner
        @network_name = network_name
        @shell_runner = shell_runner
      end

      def create
        @shell_runner.execute("docker network create #{@network_name}") if find_network.to_s == ''
      end

      def remove
        @shell_runner.execute("docker network rm #{@network_name}", true) unless find_network.to_s == ''
      end

      private 
      def find_network
        @shell_runner.execute_and_return("docker network ls | grep #{@network_name}")
      end
    end
  end
end
