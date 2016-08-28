module Minke
  module Helpers
    class Shell
      def initialize logger
        @logger = logger
      end

      ##
      # Executes a shell command and returns the return status
      def execute command
        @logger.debug command
        
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
          while line = stdout.gets
            @logger.debug line
          end
          
          exit_status = wait_thr.value
          unless exit_status.success?
            @logger.error "Error executing command: #{command}"
            abort
          end
        end
      end

      def execute_and_return command
        log = `#{command}`
        return log.strip
      end

      def mktmpdir
        Dir.mktmpdir
      end

      def remove_entry_secure dir
        FileUtils.remove_entry_secure dir
      end

      def write_file filename, data
        File.open(filename, 'w') { |file| file.write(data) }
      end

      def read_file filename
        File.open(filename, 'rb') { |file| file.read }.strip
      end

      def exist? filename
        File.exist? filename
      end
    end
  end
end