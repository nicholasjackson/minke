module Minke
  module Tasks
    class Run < Task

      def run args = nil
        @logger.info "## Run application with docker compose"

        compose_file = @config.compose_file_for(@task_name)
        compose_file = File.expand_path(compose_file)
        compose = @docker_compose_factory.create compose_file unless compose_file == nil

        run_with_block do
          begin
            compose.up
            compose.logs
          rescue SystemExit, Interrupt
            @logger.info "Stopping...."
            raise SystemExit
          ensure
            compose.down
          end
        end
      end

    end
  end
end
