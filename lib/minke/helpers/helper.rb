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
        FileUtils.cp_r from, to
      end

      ##
      # invoke a rake task
      def invoke_task task
        Rake::Task[task].invoke
      end

      def load_consul_data server, config_file
        wait_for_HTTPOK "#{server}/v1/status/leader", 0, 1
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        puts config_file
        loader.load_config config_file, server
      end

      def execute_shell_command command
        puts `#{command}`
        $?.exitstatus
      end

      def fatal_error message
        abort message
      end

      ##
      # waits until a 200 response is received from the given url
      def wait_for_HTTPOK url, count, successes = 3
        begin
          response = RestClient.send("get", url)
        rescue

        end

        if response == nil || !response.code.to_i == 200
          puts "Waiting for server #{url} to start"
          sleep 1
          if count < 180
            wait_for_HTTPOK url, count + 1
          else
            raise 'Server failed to start'
          end
        else
          if successes > 0
            puts "Server: #{url} passed health check, #{successes} checks to go..."
            sleep 1
            wait_for_HTTPOK url, count + 1, successes - 1
          else
            puts "Server: #{url} healthy"
          end
        end
      end

    end
  end
end
