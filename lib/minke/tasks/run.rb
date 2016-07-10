module Minke
  module Tasks
    class Run < Task

      def run args = nil
        puts "## Run application with docker compose"

        compose_file = @config.compose_file_for(@task)
        compose = @docker_compose_factory.create compose_file unless compose_file == nil

      	begin
          compose.up

          run_with_block do
            compose.logs
          end

      	ensure
      		compose.down
      	end
      end

    end
  end
end
