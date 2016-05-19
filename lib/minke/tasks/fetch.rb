module Minke
  module Tasks
    class Fetch < Task

      def run args = nil
        puts "## Update dependencies"
        run_with_block do
          @generator_settings.build_settings.build_commands.fetch.each do |command|
            run_command_in_container command
          end
        end
      end

    end
  end
end