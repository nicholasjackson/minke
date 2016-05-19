module Minke
  module Docker
    class SystemRunner

      def execute command
        system("#{command}")
      end

      def execute_and_return command
        log = `#{command}`
        return log.strip
      end

    end
  end
end
