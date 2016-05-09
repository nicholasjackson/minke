module Minke
  module Tasks
    class Fetch < Task

      def run args = nil
        run_with_block do
          @generator_settings.generate_settings.command.fetch.each do |command|
          	run_command_in_container command
          end
        end
      end

    end
  end
end
