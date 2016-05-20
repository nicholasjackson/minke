module Minke
  module Tasks
    ##
    # Task is a base implementation of a rake task such as fetch, build, etc
    class Task

      def initialize config, task, generator_settings, docker_runner, docker_compose_factory, logger, helper
        @config = config
        @task = task
        @generator_settings = generator_settings
        @docker_runner = docker_runner
        @logger = logger
        @helper = helper
        @task_settings = config.send(task)

        @build_image = @generator_settings.build_settings.docker_settings.image
        @build_image = config.build_image_for(task) unless config.build_image_for(task) == nil

        @build_file = config.build_docker_file_for(task)

        @compose_file = config.compose_file_for(task)

        @compose = docker_compose_factory.create @compose_file unless @compose_file == nil
      end

      ##
      # run_with_config executes the task steps for the given
      # - block containing custom actions
      def run_with_block
        #TODO: Need to add some tests for this stuff
        run_steps @task_settings.pre unless @task_settings == nil || @task_settings.pre == nil

        yield if block_given?

        run_steps @task_settings.post unless @task_settings == nil || @task_settings.post == nil
      end

      ##
      # execute the defined steps in the given Minke::Config::TaskRunSettings
      def run_steps steps
        execute_rake_tasks steps.tasks unless steps.tasks == nil
        load_consul_data steps.consul_loader unless steps.consul_loader == nil
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
        @helper.load_consul_data build_address(config.url), config.config_file
      end

      def wait_for_health_check url
        @helper.wait_for_HTTPOK build_address(url), 0, 3
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

      def build_address url
        if url.type == 'public'
          "#{url.protocol}://#{url.address}:#{url.port}#{url.path}"
        else
          public_address = @compose.public_address url.address, url.port
          "#{url.protocol}://#{public_address}#{url.path}"
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
