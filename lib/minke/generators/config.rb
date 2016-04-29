module Minke
  module Generators
    class Config
      attr_accessor :name
      attr_accessor :template_location
      attr_accessor :generate_command
      attr_accessor :generate_command_docker_image
      attr_accessor :generate_command_docker_file
      attr_accessor :build_commands
    end
  end
end
