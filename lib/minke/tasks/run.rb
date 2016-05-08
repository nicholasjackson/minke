module Minke
  module Tasks
    class Run < Task

      def run
        puts "## Run application with docker compose"

        config = Minke::Helpers.config

        if config['run']['docker'] != nil && config['run']['docker']['compose_file'] != nil
          config_file = config['run']['docker']['compose_file']
        else
          config_file = config['docker']['compose_file']
        end

        compose = Minke::DockerCompose.new config_file

      	begin
          compose.up

          # do we need to run any tasks after the server starts?
          if config['run']['after_start'] != nil
            config['run']['after_start'].each do |task|
              puts "## Running after_start task: #{task}"
              Rake::Task[task].invoke

              puts ""
            end
          end

          if config['run']['consul_loader']['enabled']
            Minke::Helpers.wait_until_server_running "#{config['run']['consul_loader']['url']}/v1/status/leader", 0
            loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
            loader.load_config config['run']['consul_loader']['config_file'], config['run']['consul_loader']['url']

            puts ""
          end

          compose.logs
      	rescue SystemExit, Interrupt
      		compose.stop
      		compose.rm unless Docker.info["Driver"] == "btrfs"
      	end
      end

    end
  end
end
