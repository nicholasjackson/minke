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
        @error_helper           = args[:error_helper]
        @shell_helper           = args[:shell_helper]
        @logger_helper          = args[:logger_helper]
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
        puts "Starting Consul"
        begin
          @docker_network.create
          @consul.start_and_load_data @task_settings.consul_loader unless @task_settings.consul_loader == nil
          @task_runner.run_steps(@task_settings.pre) unless @task_settings == nil || @task_settings.pre == nil

          yield if block_given?

          @task_runner.run_steps(@task_settings.post) unless @task_settings == nil || @task_settings.post == nil
        ensure
          puts "Stopping Consul"
          @consul.stop unless @task_settings.consul_loader == nil
          sleep 3
          @docker_network.remove
        end
      end

      ##
      # runs the given command in a docker container
      def run_command_in_container command
        begin
          settings = @generator_config.build_settings.docker_settings
          build_image = create_container_image

          args = {
            :image             => build_image,
            :command           => command,
            :volumes           => settings.binds,
            :environment       => settings.env,
            :working_directory => settings.working_directory
          }
          container, success = @docker_runner.create_and_run_container args

          # throw exception if failed
          @error_helper.fatal_error "Unable to run command #{command}" unless success
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
          @docker_runner.build_image build_file, build_image
        else
          @docker_runner.pull_image build_image unless @docker_runner.find_image build_image
        end

        build_image
      end

    end
  end
end
