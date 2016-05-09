module Minke
  module Helpers
    class Helper
      ##
      # copy assets from one location to another
      def copy_assets from, to
        directory = to
        if File.directory?(to)
          directory = File.dirname(to)
        end

        Dir.mkdir directory unless Dir.exist? to
        FileUtils.cp from, to
      end

      ##
      # invoke a rake task
      def invoke_task task
        Rake::Task[task].invoke
      end

      def load_consul_data server, config_file

      end

      def execute_shell_command command
        sh command
        $?.exitstatus
      end

      def fatal_error message
        abort message
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
