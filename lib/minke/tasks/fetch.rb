module Minke
  module Tasks
    class Fetch < Task

      def run
        run_with_config @config, @config.fetch do
          @generator_settings.command.fetch.each do |command|
          	run_command_in_container command
          end
        end
      end

    end
  end
end
