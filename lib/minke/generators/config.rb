module Minke
  module Generators

    ##
    # This class encapsulates the config required by the generator.
    class Config
      ##
      # Name of the generator.
      attr_accessor :name

      ##
      # Location of the ERB template files
      attr_accessor :template_location

      ##
      # Instance of Minke::Generators::GenerateSettings
      attr_accessor :generate_settings

      ##
      # Instance of Minke::Generators::BuildSettings
      attr_accessor :build_settings
    end

    ##
    # This class encapsulates the settings required to generate a new template.
    class GenerateSettings
      ##
      # [OPTIONAL]
      # A command to execute when generating a new template.
      #
      # Using this attribute it is possible to delegate reponsibility for generation of part of the codebase
      # to an external command.
      # For example you could execute rails new... to generate a new rails project as part of the template
      # generation.
      attr_accessor :command

      ##
      # The name of a docker image to run the commands inside.
      #
      # All commands are run inside a docker container to remove the dependency on installed software
      # on the build machine.
      attr_accessor :docker_image

      ##
      # The folder location of a docker file from which an image will be build before running commands inside it.
      #
      # This option can be used as an alternative to providing a docker image, Dockerfiles can be bundled with the
      # template.
      # Minke will attempt to create an image from this Dockerfile before executing the generate commands.
      attr_accessor :docker_file
    end

    ##
    # BuildSettings contains the commands and settings used to build and test your code, these are not
    # related to template generation but when Minke is used to build source created from a template.
    class BuildSettings
      ##
      # Instance of Minke::Generators::BuildCommands
      attr_accessor :build_commands

      ##
      # Instance of Minke::Generators::DockerSettings
      attr_accessor :docker_settings
    end

    ##
    # BuildCommands define the command that will be executed in the docker container for each
    # of the build steps.
    class BuildCommands

      ##
      # An array of commands to execute for the fetch step.
      attr_accessor :fetch

      ##
      # An array of commands to execute for the build step.
      attr_accessor :build

      ##
      # An array of commands to execute for the test step.
      attr_accessor :test
    end

    ##
    # DockerSettings encapsulates the settings required for the Docker container
    # within which the commands will execute.
    class DockerSettings

      ##
      # Docker image used to execute commands
      attr_accessor :image

      ##
      # Docker environment to set on running container
      attr_accessor :env

      ##
      # Volume mapping information for Docker container, must be fully qualified path
      attr_accessor :binds

      ##
      # Workging directory for executed commands
      attr_accessor :working_directory
    end
  end
end
