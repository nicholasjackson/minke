module Minke
  module Tasks
    class Push < Task

      def run args = nil
        @logger.info "## Push image to registry"

        url = @config.docker_registry.url
        user = @config.docker_registry.user
        password = @config.docker_registry.password
        email = @config.docker_registry.email
        namespace = @config.docker_registry.namespace
        image_tag = "#{namespace}/#{@config.application_name}"

        @docker_runner.login_registry url, user, password, email
        @docker_runner.tag_image @config.application_name, image_tag
        @docker_runner.push_image image_tag
      end

    end
  end
end
