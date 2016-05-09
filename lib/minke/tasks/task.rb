module Minke
  module Tasks
    ##
    # Task is a base implementation of a rake task such as fetch, build, etc
    class Task

      def initialize config, task_settings, generator_settings, docker_runner, docker_compose_factory, logger, helper
        @config = config
        @task_settings = task_settings
        @generator_settings = generator_settings
        @docker_runner = docker_runner
        @docker_compose_factory = docker_compose_factory
        @logger = logger
        @helper = helper

        @build_image = @generator_settings.build_settings.docker_settings.image
        @build_image = config.docker.build_image unless config.docker.build_image == nil

        @build_file = config.docker.build_docker_file unless config.docker.build_docker_file == nil
        @build_image = task_settings.docker.build_image unless task_settings.docker == nil || task_settings.docker.build_image == nil
        @build_file = task_settings.docker.build_docker_file unless task_settings.docker == nil || task_settings.docker.build_docker_file == nil
      end

      ##
      # run_with_config executes the task steps for the given
      # - block containing custom actions
      def run_with_block
        #TODO: Need to add some tests for this stuff
        run_steps @task_settings.pre unless @task_settings.pre == nil

        yield if block_given?

        run_steps @task_settings.post unless @task_settings.post == nil
      end

      ##
      # execute the defined steps in the given Minke::Config::TaskRunSettings
      def run_steps steps
        execute_rake_tasks steps.tasks unless steps.tasks == nil
        load_consul_data steps.consul_loader unless steps.consul_loader == nil
        steps.consul_loader unless steps.consul_loader == nil
        wait_for_health_check steps.health_check unless steps.health_check == nil
        copy_assets steps.copy unless steps.copy == nil
      end

      ##
      # execute an array of rake tasks
      def execute_rake_tasks tasks
        tasks.each { |t| @helper.invoke_task t }
      end

      ##
      # load consul config
      def load_consul_data config
        @helper.load_consul_data config.url, config.config_file
      end

      def wait_for_health_check url
        @helper.wait_for_HTTPOK url, 3, 0
      end

      def copy_assets assets
        assets.each { |a| @helper.copy_assets a.from, a.to }
      end

      def run_command_in_container command
        begin
          settings = @generator_settings.build_settings.docker_settings
          if @build_file != nil
            @build_image = "#{@config.application_name}-buildimage"
            @docker_runner.build_image @build_file, @build_image
          end

          container, success = @docker_runner.create_and_run_container @build_image, settings.binds, settings.env, settings.working_directory, command

          # throw exception if failed
          @helper.fatal_error "Unable to run command #{command}" unless success
        ensure
          @docker_runner.delete_container container
        end
      end

      def log message, level
        ## implement logger implementation
        case level
        when :error
          @logger.error message
        when :info
          @logger.info message
        when :debug
          @logger.debug message
        end
      end

    end
  end
end
