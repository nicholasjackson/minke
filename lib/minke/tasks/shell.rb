module Minke
  module Tasks
    class Shell < Task

      def run args = nil
        @logger.info "## Run shell" 

        @logger.info "## Run application with docker compose"

        compose_file = @config.compose_file_for(@task_name)
        compose_file = File.expand_path(compose_file)
        compose = @docker_compose_factory.create compose_file unless compose_file == nil
        
        run_with_block do |pre_tasks, post_tasks|
          begin
            compose.up
            pre_tasks.call
            run_command_in_container '/bin/sh', true
          rescue SystemExit, Interrupt
            @logger.info "Stopping...."
            raise SystemExit
          ensure
            compose.down
            post_tasks.call
          end
        end
      end

    end
  end
end
