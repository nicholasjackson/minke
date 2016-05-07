module Minke
  module Generators

    ##
    # ConfigProcessor replaces variable placeholders in the config object
    # with the values specified in the initialize method
    class ConfigProcessor

      ##
      # initialize takes a single parameter of Minke::Generators::ConfigVariables
      def initialize variables
        @variables = variables
      end

      ##
      # process a Minke::Generators::Config object and replace given variables
      def process config
        replace_variables config.template_location

        replace_variables config.generate_settings.command
        replace_variables config.generate_settings.docker_file

        replace_variables config.build_settings.build_commands.fetch
        replace_variables config.build_settings.build_commands.build
        replace_variables config.build_settings.build_commands.test

        replace_variables config.build_settings.docker_settings.image
        replace_variables config.build_settings.docker_settings.env
        replace_variables config.build_settings.docker_settings.binds
        replace_variables config.build_settings.docker_settings.working_directory
      end

      def replace_variables section
        if section.is_a?(Array)
          section.each { |a| replace_variables a }
        else
          section.gsub! '##SRC_ROOT##', @variables.src_root
        end
      end
    end

  end
end
