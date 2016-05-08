module Minke
  module Tasks
    class Cucumber < Task

      def run
        config = Minke::Helpers.config

      	puts "## Running cucumber with tags #{args[:feature]}"

      	if args[:feature] != nil
      		feature = "--tags #{args[:feature]}"
      	else
      		feature = ""
      	end

      	status = 0

        config = Minke::Helpers.config

        if config['cucumber']['docker'] != nil && config['cucumber']['docker']['compose_file'] != nil
          config_file = config['cucumber']['docker']['compose_file']
        else
          config_file = config['docker']['compose_file']
        end

        compose = Minke::DockerCompose.new config_file

      	begin
      	  compose.up

          # do we need to run any tasks after the server starts?
          if config['cucumber']['after_start'] != nil
            config['cucumber']['after_start'].each do |task|
              puts "## Running after_start task: #{task}"

              begin
                Rake::Task[task].invoke
              rescue Exception => msg
                puts "Error running rake task: #{msg}"
                raise msg
              end
              puts ""
            end
          end

          if config['cucumber']['consul_loader']['enabled']
            Minke::Helpers.wait_until_server_running "#{config['cucumber']['consul_loader']['url']}/v1/status/leader", 0
            loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
            loader.load_config config['cucumber']['consul_loader']['config_file'], config['cucumber']['consul_loader']['url']
          end

          if config['cucumber']['health_check']['enabled']
            Minke::Helpers.wait_until_server_running config['cucumber']['health_check']['url'], 0, 3
          end

      		sh "cucumber --color -f pretty #{feature}"
          status = $?.exitstatus
      	ensure
      		compose.stop
      		compose.rm unless Docker.info["Driver"] == "btrfs"

          abort "Cucumber steps failed" unless status == 0
      	end
      end

    end
  end
end
