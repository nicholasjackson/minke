module Minke
  module Helpers
    class WaitForServer

      def wait_until_server_running server, count, successes = 0
        begin
          response = RestClient.send("get", server)
        rescue

        end

        if response == nil || !response.code.to_i == 200
          puts "Waiting for server #{server} to start"
          sleep 1
          if count < 20
            self.wait_until_server_running server, count + 1
          else
            raise 'Server failed to start'
          end
        else
          if successes > 0
            puts "Server: #{server} passed health check, #{successes} checks to go..."
            sleep 1
            wait_until_server_running server, count + 1, successes - 1
          else
            puts "Server: #{server} healthy"
          end
        end
      end

    end
  end
end
