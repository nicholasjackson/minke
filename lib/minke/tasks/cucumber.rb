module Minke
  module Tasks
    class Cucumber < Task

      def run args = nil
      	puts "## Running cucumber with tags #{args}"

        compose_file = @config.compose_file_for(@task_name)
        compose = @docker_compose_factory.create compose_file unless compose_file == nil

      	begin
          status = 0
      	  compose.up

          run_with_block do
            status = @shell_helper.execute "cucumber --color -f pretty #{get_features args}"
          end

      	ensure
      		compose.down

          @error_helper.fatal_error "Cucumber steps failed" unless status == 0
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
