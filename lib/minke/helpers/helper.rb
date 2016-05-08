module Minke
  module Helpers
    class Helper
      ##
      # copy assets from one location to another
      def copy_assets assets
        assets.each do |a|
          directory = a['to']
          if File.directory?(a['to'])
            directory = File.dirname(a['to'])
          end

          Dir.mkdir directory unless Dir.exist? a['to']
          FileUtils.cp a['from'], a['to']
        end

        ##
        # invoke a rake task
        def invoke_task task
          Rake::Task[task].invoke
        end

        def load_consul_data server, config_file
          
        end

        ##
        # waits until a 200 response is received from the given url
        def wait_for_HTTPOK url, count, successes = 0
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
end
