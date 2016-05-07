module Minke

  ##
  # Config represents system wide configuration for minke
  class Config

    attr_accessor :project_config
    attr_accessor :generator_config

    def initialize config_file, generator_config, params
      self.project_config = YAML.parse(ERB.new(File.read(config_file)).result).transform
      self.generator_config = generator_config
    end

  end
end
