module Minke
  module Config
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
  end
end
