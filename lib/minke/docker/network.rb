module Minke
  module Docker
    class Network
      def initialize network_name, shell_runner
        @network_name = network_name
        @shell_runner = shell_runner
        @created_network = false
      end

      def create
        if find_network.to_s == ''
          @shell_runner.execute("docker network create #{@network_name}") 
          @created_network = true
        end
      end

      def remove
        puts "OKs" + @created_network.to_s
        if find_network.to_s != '' && @created_network == true
          @shell_runner.execute("docker network rm #{@network_name}", true)
        end
      end

      private 
      def find_network
        @shell_runner.execute_and_return("docker network ls | grep #{@network_name}")
      end
    end
  end
end
