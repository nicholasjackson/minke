module Minke
  module Tasks
    class Task
      def initialize config, docker_runner
        @config = config
        @docker_runner = docker_runner
      end

      def run_command_in_container command
        begin
          container, ret = @docker_runner.create_and_run_container config, command

          # throw exception if failed
        ensure
          Minke::Docker.delete_container container
        end
      end
    end
  end
end
