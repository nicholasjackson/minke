module Minke
  module Tasks
    class Cucumber < Task

      def run args = nil
      	puts "## Running cucumber with tags #{args}"

        compose_file = @config.docker.application_compose_file unless @config.docker.application_compose_file == nil
        compose_file = @config.cucumber.docker.application_compose_file unless @config.cucumber.docker == nil || @config.cucumber.docker.application_compose_file == nil

        compose = @docker_compose_factory.create compose_file

      	begin
          status = 0
      	  compose.up

          run_with_block do
            status = @helper.execute_shell_command "cucumber --color -f pretty #{get_features args}"
          end

      	ensure
      		compose.stop
      		compose.rm

          @helper.fatal_error "Cucumber steps failed" unless status == 0
      	end
      end

      def get_features args
        if args != nil && args[:feature] != nil
      		feature = "--tags #{args[:feature]}"
      	else
      		feature = ""
      	end
      end

    end
  end
end
