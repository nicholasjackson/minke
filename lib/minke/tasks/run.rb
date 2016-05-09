module Minke
  module Tasks
    class Run < Task

      def run args = nil
        puts "## Run application with docker compose"
        compose_file = @config.docker.application_compose_file unless @config.docker.application_compose_file == nil
        compose_file = @config.cucumber.docker.application_compose_file unless @config.run.docker == nil || @config.run.docker.application_compose_file == nil

        compose = @docker_compose_factory.create compose_file

      	begin
      	  compose.up

          run_with_block

      	ensure
      		compose.stop
      		compose.rm
      	end
      end

    end
  end
end
