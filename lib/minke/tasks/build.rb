module Minke
  module Tasks
    class Build < Task

      def run args = nil
        @logger.info "## Build application" 

        if  @generator_config.build_settings.build_commands.build != nil
          run_with_block do |pre_tasks, post_tasks|
            pre_tasks.call

            @generator_config.build_settings.build_commands.build.each do |command|
              @logger.debug command.to_s
              run_command_in_container command
            end

            post_tasks.call
          end
        end
      end

    end
  end
end
