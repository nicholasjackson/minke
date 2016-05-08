module Minke
  module Tasks
    class Build < Task

      def run
        puts "## Build application"

        if config['build'] != nil && config['build']['before'] != nil
          config['build']['before'].each do |task|
            puts "## Running before build task: #{task}"
            Rake::Task[task].invoke

            puts ""
          end
        end

        config[:build_config][:build][:build].each do |command|
        	begin
        		# Build application
            container, ret = Minke::Docker.create_and_run_container config, command
            raise Exception, 'Error running command' unless ret == 0
          ensure
        		Minke::Docker.delete_container container
        	end
        end

        puts ""
      end
    end

  end
