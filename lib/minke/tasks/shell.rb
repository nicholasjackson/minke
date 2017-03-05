module Minke
  module Tasks
    class Shell < Task

      def run args = nil
        @logger.info "## Run shell" 
        @logger.info "## Run application with docker compose"

        compose_file = @config.compose_file_for(@task_name)
        compose_file = File.expand_path(compose_file)
        compose = @docker_compose_factory.create compose_file unless compose_file == nil

        run_with_block do |pre_tasks, post_tasks|
          begin
            services = create_list_of_links(compose.services)
            compose.up
            pre_tasks.call

            @logger.info "## Shell open to build container"
            run_command_in_container(['/bin/sh','-c','ls && /bin/sh'], true, services, @task_settings.ports)
          rescue SystemExit, Interrupt
            @logger.info "Stopping...."
            raise SystemExit
          ensure
            compose.down
            post_tasks.call
          end
        end
      end

      def create_list_of_links compose_services
        services = []
        compose_services.each do |k,v| 
          services.push(k) 
        end

        services
      end
    end

  end
end
