module Minke
  module Tasks
    class Build < Task

      def run args = nil
        puts "## Build application"
        run_with_block do
          @generator_settings.build_settings.build_commands.build.each do |command|
            puts command.to_s
          	run_command_in_container command
          end
        end
      end

    end
  end
end
