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

    ##
    # DockerRegistrySettings encapsulates the settings related to the docker registry
    class DockerRegistrySettings
      ##
      # url of the docker registry to use.
      #
      # [Optional]
      attr_accessor :url

      ##
      # user to use when logging into a docker registry.
      #
      # [Optional]
      attr_accessor :user

      ##
      # password to use when logging into a docker registry.
      #
      # [Optional]
      attr_accessor :password

      ##
      # email to use when logging into a docker registry.
      #
      # [Optional]
      attr_accessor :email

      ##
      # namespace to use when tagging an image for the docker registry.
      #
      # [Required]
      attr_accessor :namespace
    end

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

    ##
    # Task encapsulates the configuration for the various rake tasks like build, run, etc.
    class Task
      ##
      # consul_loader will specify that the given config file is loaded into Consul.
      # instance of Minke::Config::ConsulLoader
      #
      # [Optional]
      attr_accessor :consul_loader

      ##
      # health_check is the string representation of a url to check before continuing with the rest of the
      # task a successfull 200 response from the endpoint is required to contine.
      #
      # [Optional]
      attr_accessor :health_check

      ##
      # pre tasks will run before the main task executes.
      # instance of Minke::Config::TaskRunSettings
      #
      # [Optional]
      attr_accessor :pre

      ##
      # post tasks will run after the main task executes.
      # instance of Minke::Config::TaskRunSettings
      #
      # [Optional]
      attr_accessor :post

      ##
      # docker config allows you to override the main docker configuration on a per task basis.
      # instance of Minke::Config::TaskRunSettings
      #
      # [Optional]
      attr_accessor :docker

      ##
      # ports contains an array of Minke::Config::ContainerAddress which holds the details
      # for the address the public and private ports of any containers which will be started by this
      # task.
      attr_accessor :ports
    end

    ##
    # TaskRunSettings encapsulates the configuration for the various pre and post sections for each task.
    # You can use this section to load config into consul, wait for a health check to complete, copy files
    # or execute other tasks defined in your Rakefile.
    class TaskRunSettings
      ##
      # tasks is an array of strings which point to a defined task in your Rakefile.
      #
      # [Optional]
      attr_accessor :tasks

      ##
      # copy is an array of Copy instances which will be copied before the task continues.
      # instance of Minke::Config::Copy
      #
      # [Optional]
      attr_accessor :copy
    end

    ##
    # ConsulLoader defines the settings and url to be loaded into a running consul instance.
    class ConsulLoader
      ##
      # config_file points to a yaml file of key values to load into consul.
      #
      # [Required]
      attr_accessor :config_file

      ##
      # url is the url to the running consul instance into which the keys and values will be loaded.
      #
      # [Required]
      attr_accessor :url
    end

    ##
    # Copy defines a source and destination of either a file or directory to be copied during a task.
    class Copy
      ##
      # from is the file or directory to copy from.
      #
      # [Required]
      attr_accessor :from

      ##
      # to is the file or directory to copy to.
      #
      # [Required]
      attr_accessor :to
    end

    ##
    # URL represents a url object which is used for health_check and consul_loader locations
    class URL
      ##
      # address of the server i.e 127.0.0.1 or the docker name consul
      attr_accessor :address

      ##
      # port which the server is running on
      # default 80
      attr_accessor :port

      ##
      # protocol for the server
      # - http [default]
      # - https
      attr_accessor :protocol

      ##
      # path for the server
      # default /
      attr_accessor :path

      ##
      # type of the URL
      # - public
      # - private used for linked containers
      attr_accessor :type
    end

  end
end
