module Minke
  module Generators

    ##
    # ConfigVariables encapsulates the variables that are evaluated at runtime when
    # a template is loaded.
    class ConfigVariables

      ##
      # src_root is the absolute path where the src files will be generated
      attr_accessor :src_root

      ##
      # namespace is the namespace of the application
      attr_accessor :namespace

      ##
      # application_name is the name of the application
      attr_accessor :application_name
    end

  end
end
