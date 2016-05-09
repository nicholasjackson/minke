module Minke
  module Tasks
    class Test < Task

      def run args = nil
        puts "## Test application"

        run_with_block do
          @generator_settings.generate_settings.command.test.each do |command|
          	run_command_in_container command
          end
        end
      end

    end
  end
end
