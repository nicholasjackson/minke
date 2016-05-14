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

        replace_variables config.generate_settings.command unless config.generate_settings == nil || config.generate_settings.command == nil
        replace_variables config.generate_settings.docker_file unless config.generate_settings == nil || config.generate_settings.docker_file == nil

        replace_variables config.build_settings.build_commands.fetch unless config.build_settings == nil || config.build_settings.build_commands.fetch == nil
        replace_variables config.build_settings.build_commands.build unless config.build_settings == nil || config.build_settings.build_commands.build == nil
        replace_variables config.build_settings.build_commands.test unless config.build_settings == nil || config.build_settings.build_commands.test == nil

        replace_variables config.build_settings.docker_settings.image unless config.build_settings == nil || config.build_settings.docker_settings.image == nil
        replace_variables config.build_settings.docker_settings.env unless config.build_settings == nil || config.build_settings.docker_settings.env == nil
        replace_variables config.build_settings.docker_settings.binds unless config.build_settings == nil || config.build_settings.docker_settings.binds == nil
        replace_variables config.build_settings.docker_settings.working_directory unless config.build_settings == nil || config.build_settings.docker_settings.working_directory == nil

        return config
      end

      def replace_variables section
        if section.is_a?(Array)
          section.each { |a| replace_variables a }
        else
          section.gsub! '<%= application_name %>', @variables.application_name
          section.gsub! '<%= namespace %>', @variables.namespace
          section.gsub! '<%= src_root %>', @variables.src_root
        end
      end
    end

  end
end
