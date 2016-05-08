module Minke
  module Tasks
    class Build < Task

      def run
        puts "## Build application"
        config = Minke::Helpers.config

        # do we need to build a custom build container
        if config['docker']['build'] && config['docker']['build']['docker_file'] != nil
          puts "## Building custom docker image"

          docker_file = config['docker']['build']['docker_file']
          image_name = config['application_name'] + "-buildimage"

          Docker.options = {:read_timeout => 6200}
        	image = Docker::Image.build_from_dir docker_file, {:t => image_name}
          config[:build_config][:docker][:image] = image_name
        elsif config['docker']['build'] && config['docker']['build']['image'] != nil
          config[:build_config][:docker][:image] = config['docker']['build']['image']
        end

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
