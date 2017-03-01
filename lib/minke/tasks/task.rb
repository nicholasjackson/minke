module Minke
  module Tasks
    ##
    # Task is a base implementation of a rake task such as fetch, build, etc
    class Task

      def initialize args
        @config                 = args[:config]
        @task_name              = args[:task_name]
        @docker_runner          = args[:docker_runner]
        @task_runner            = args[:task_runner]
        @shell_helper           = args[:shell_helper]
        @logger                 = args[:logger_helper]
        @generator_config       = args[:generator_config]
        @docker_compose_factory = args[:docker_compose_factory]
        @consul                 = args[:consul]
        @docker_network         = args[:docker_network]
        @health_check           = args[:health_check]
        @service_discovery      = args[:service_discovery]
        @task_settings          = @config.send(@task_name)
      end

      ##
      # run_with_config executes the task steps for the given
      # - block containing custom actions
      def run_with_block
        success = true

        begin
          @docker_network.create
          @consul.start_and_load_data @task_settings.consul_loader unless @task_settings.consul_loader == nil
          
          pre_func = -> {
            @task_runner.run_steps(@task_settings.pre) unless @task_settings == nil || @task_settings.pre == nil
          }

          post_func = -> {
            @task_runner.run_steps(@task_settings.post) unless @task_settings == nil || @task_settings.post == nil
          } 
          
          if block_given?
            yield(pre_func, post_func)
          else
            pre_func.call
            post_func.call
          end
        rescue Exception => e
          @logger.error e.message
          success = false
        ensure
          @consul.stop unless @task_settings.consul_loader == nil
          begin
            @docker_network.remove
          rescue Exception => e
            # Trap removing a network as minke may have been called with an existing network and containers
            # may still be attached.
            @logger.error e.message
          end
        end

        abort unless success
      end

      ##
      # runs the given command in a docker container
      def run_command_in_container command, blocking
        begin
          @logger.info "Running command: #{command}"
          settings = @generator_config.build_settings.docker_settings
          volumes           = settings.binds.clone unless settings.binds == nil
          environment       = settings.env.clone unless settings.env == nil
          build_image       = create_container_image
          working_directory = create_working_directory

          if ENV['AGENT_SOCK'] != nil
            volumes.push "#{ENV['AGENT_SOCK']}:/ssh-agent"
            environment.push "SSH_AUTH_SOCK=/ssh-agent"
            environment.push "GIT_SSH_COMMAND=ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
          end

          args = {
            :image             => build_image,
            :command           => command,
            :volumes           => volumes,
            :environment       => environment,
            :working_directory => working_directory
          }

          if blocking == false
            container, success = @docker_runner.create_and_run_container args
          else 
            container, success = @docker_runner.create_and_run_blocking_container args
          end

          # throw exception if failed
          raise "Unable to run command #{command}" unless success
        ensure
          @docker_runner.delete_container container
        end
      end

      ##
      # Pulls the build image for the container from the registry if one is supplied,
      # if a build file is specified an image is built.
      def create_container_image
        build_image = @generator_config.build_settings.docker_settings.image
        build_image = @config.build_image_for(@task_name) unless @config.build_image_for(@task_name) == nil

        build_file = @config.build_docker_file_for(@task_name)

        if build_file != nil
          build_image = "#{@config.application_name}-buildimage"
          
          @logger.debug "Building image: #{build_image} from file #{build_file}"
          @docker_runner.build_image build_file, build_image
        else
          @logger.debug "Pulling image: #{build_image}"
          @docker_runner.pull_image build_image unless @docker_runner.find_image build_image
        end

        build_image
      end

      def create_working_directory
        base_path = @generator_config.build_settings.docker_settings.working_directory
        override_path = @task_settings.docker.working_directory unless @task_settings.docker == nil

        if override_path != nil
          path = Pathname.new(base_path)
          return (path + override_path).to_s
        else 
          return base_path
        end
      end

    end
  end
end
