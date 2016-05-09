module Minke
  module Tasks
    ##
    # Task is a base implementation of a rake task such as fetch, build, etc
    class Task

      def initialize config, generator_settings, docker_runner, logger, helper
        @config = config
        @generator_settings = generator_settings
        @docker_runner = docker_runner
        @logger = logger
        @helper = helper
      end

      ##
      # run_with_config executes the task steps for the given Minke::Config::TaskRunSettings and Minke::Config::DockerSettings
      def run_with_config main_config, task_config
        custom_dir = main_config.docker.build_docker_file || task_config.docker.build_docker_file
        if custom_dir != nil
          @docker_runner.build_image custom_dir, "#{main_config.application_name}-buildimage"
        end

        run_steps task_config.pre unless task_config.pre == nil
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
          container, ret = @docker_runner.create_and_run_container @config, command

          # throw exception if failed
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
