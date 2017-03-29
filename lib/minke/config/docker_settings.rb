module Minke
  module Config
    ##
    # DockerSettings encapsulate the configuration used when running builds using docker.
    class DockerSettings
      ##
      # Docker Image to use when building the application source code.
      #
      # [Optional]
      attr_accessor :build_image

      ##
      # Specific docker settings to allow an override of the defaults provided by the template, you may want to use
      # this if you require a specific piece of software to be installed on the build container.
      #
      # [Optional]
      attr_accessor :build_docker_file

      ##
      # Dockerfile to use when creating the final docker image.
      #
      # [Required]
      attr_accessor :application_docker_file

      ##
      # Docker compose file to use when running and executing cucumber tests.
      #
      # [Required]
      attr_accessor :application_compose_file

      ##
      # Working directory to use for build root, relative to project root
      #
      # [Optional]
      attr_accessor :working_directory
    end
  end
end
