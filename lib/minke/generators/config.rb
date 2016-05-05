module Minke
  module Generators
    class Config
      attr_accessor :name
      attr_accessor :template_location
      attr_accessor :generate_command
      attr_accessor :generate_command_docker_image
      attr_accessor :generate_command_docker_file
      attr_accessor :build_commands

      def initialize
        build_commands = BuildCommands.new
      end
    end

    class BuildCommands
      attr_accessor :build
      attr_accessor :docker

      def initialize
        self.build = BuildSection.new
        self.docker = DockerSection.new
      end
    end

    class BuildSection
      attr_accessor :clean # commands to clean the current build => [['make', 'clean'], ['rm', '-rf', './build']]
      attr_accessor :get # commands to fetch any dependent packages => [['make', 'fetch']]
      attr_accessor :compile # commands to compile the source code => [['make', 'build']]
      attr_accessor :test # commands to execute code level tests => [['make', 'test']]
    end

    class DockerSection
      attr_accessor :image # docker image to use for builds => 'frolvlad/alpine-oraclejdk8:slim'
      attr_accessor :binds # docker volume binding information => ['src:/src']
      attr_accessor :working_directory # working directory to run commands in => '/src'
    end
  end
end

{
          :build => {
            :compile => [['mvn','package']]
          },
          :docker => {
            :image => 'frolvlad/alpine-oraclejdk8:slim',
            :binds => ["##SRC_ROOT##:/src", "##SRC_ROOT##/.m2:/root/.m2"],
            :working_directory => "/src"
          }
        }
