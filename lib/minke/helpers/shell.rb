module Minke
  module Helpers

    class Shell
      ##
      # Executes a shell command and returns the return status
      def execute_shell_command command
        puts `#{command}`
        $?.exitstatus
      end
    end

  end
end