module Minke
  module Tasks
    class Fetch < Task

      def run args = nil
        @logger.info '### Fetching dependencies'

        if @generator_config.build_settings.build_commands.fetch != nil
          run_with_block do |pre_tasks, post_tasks|
            pre_tasks.call
            
            @generator_config.build_settings.build_commands.fetch.each do |command|
              run_command_in_container command
            end

            post_tasks.call
          end
        end
      end

    end
  end
end
