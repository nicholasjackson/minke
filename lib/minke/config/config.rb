module Minke
  module Config
    ##
    # Config represents project level configuration for minke builds
    class Config
      ##
      # the namespace for the application
      #
      # [Required]
      attr_accessor :namespace

      ##
      # the name of the application
      #
      # [Required]
      attr_accessor :application_name

      ##
      # the name of the generator to use
      #
      # [Required]
      attr_accessor :generator_name

      ##
      # Docker registry settings instance of Minke::Config::DockerRegistrySettings
      #
      # [Optional]
      attr_accessor :docker_registry

      ##
      # Docker settings for tasks, any items defined in this section will override
      # the defaults provided inside the generator.
      # instance of Minke::Config::DockerSettings
      #
      # [Required]
      attr_accessor :docker

      ##
      # Settings for the fetch packages phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the fetch commands will not be executed
      attr_accessor :fetch

      ##
      # Settings for the build image phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the build commands will not be executed
      attr_accessor :build

      ##
      # Settings for the run application phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the run commands will not be executed
      attr_accessor :run

      ##
      # Settings for the run application phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the test commands will not be executed
      attr_accessor :test

      ##
      # Settings for the cuccumber functional test phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the cucumber commands will not be executed
      attr_accessor :cucumber

      ##
      # Settings for the build shell phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the shell commands will not be executed
      attr_accessor :shell
      
      ##
      # Settings for the build provision phase
      # instance of Minke::Config::Task
      #
      # [Optional] if not provided the provision commands will not be executed
      attr_accessor :provision

      ##
      # Returns the docker_compose file for the given section,
      # if the section overrides application_compose_file then this is returned
      # otherwise the global file is returned
      # Parameters
      # - :fetch
      # - :build
      # - :run
      # - :test
      # - :cucumber
      def compose_file_for section
        file = docker.application_compose_file unless docker.application_compose_file == nil

        if self.send(section) != nil &&
           self.send(section).docker != nil &&
           self.send(section).docker.application_compose_file != nil
            file = self.send(section).docker.application_compose_file
        end
        return file
      end

      ##
      # Returns the build_image file for the given section,
      # if the section overrides build_image then this is returned
      # otherwise the global build_image is returned
      # Parameters
      # - :fetch
      # - :build
      # - :run
      # - :test
      # - :cucumber
      def build_image_for section
        file = docker.build_image unless docker.build_image == nil

        if self.send(section) != nil &&
           self.send(section).docker != nil &&
           self.send(section).docker.build_image != nil
            file = self.send(section).docker.build_image
        end
        return file
      end

      ##
      # Returns the docker_compose file for the given section,
      # if the section overrides application_compose_file then this is returned
      # otherwise the global file is returned
      # Parameters
      # - :fetch
      # - :build
      # - :run
      # - :test
      # - :cucumber
      def build_docker_file_for section
        file = docker.build_docker_file unless docker.build_docker_file == nil

        if self.send(section) != nil &&
           self.send(section).docker != nil &&
           self.send(section).docker.build_docker_file != nil
            file = self.send(section).docker.build_docker_file
        end
        return file
      end
    end

  end
end
