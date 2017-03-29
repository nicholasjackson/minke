module Minke
  module Config
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
  end
end
