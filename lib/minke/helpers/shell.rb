module Minke
  module Helpers
    class Shell
      ##
      # Executes a shell command and returns the return status
      def execute command
        system("#{command}")
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
    end
  end
end