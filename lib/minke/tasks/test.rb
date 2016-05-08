module Minke
  module Tasks
    class Fetch < Task

      def run
        config = Minke::Helpers.config

        if config['test'] != nil && config['test']['before'] != nil
          config['test']['before'].each do |task|
            puts "## Running before test task: #{task}"
            Rake::Task[task].invoke

            puts ""
          end
        end

        puts "## Test application"
          if config[:build_config][:build][:test] != nil
          config[:build_config][:build][:test].each do |command|
            begin
        		  # Test application
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
  end
end
