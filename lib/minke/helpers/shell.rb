module Minke
  module Helpers
    class Shell
      ##
      # Executes a shell command and returns the return status
      def execute command
        puts command
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

      def read_file filename
        File.open(filename, 'rb') { |file| file.read }.strip
      end

      def exist? filename
        File.exist? filename
      end
    end
  end
end