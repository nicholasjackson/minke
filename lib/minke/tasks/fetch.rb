module Minke
  module Tasks
    class Fetch < Task

      def run args = nil
        @logger.info '### Fetching dependencies'

        if @generator_config.build_settings.build_commands.fetch != nil
          run_with_block do
            @generator_config.build_settings.build_commands.fetch.each do |command|
              run_command_in_container command
            end
          end
        end
      end

    end
  end
end
