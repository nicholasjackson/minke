module Minke
  module Tasks
    class BuildImage < Task

      def run args = nil
        @logger.info "## Build image"

        @docker_runner.build_image @config.docker.application_docker_file, @config.application_name
      end

    end
  end
end
