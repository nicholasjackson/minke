module Minke
  module Tasks
    ##
    # Task is a base implementation of a rake task such as fetch, build, etc
    class Task

      def initialize config, docker_runner, logger
        @config = config
        @docker_runner = docker_runner
        @logger = logger
      end

      def run_command_in_container command
        begin
          container, ret = @docker_runner.create_and_run_container @config, command

          # throw exception if failed
        ensure
          #Minke::Docker.delete_container container
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
