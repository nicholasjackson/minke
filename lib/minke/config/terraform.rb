module Minke
  module Config

    class TerraformSettings
      ##
      # config_dir is the relative folder containing your terraform config.
      attr_accessor :config_dir

      ##
      # environment contains the environment variable settings to be used with
      # terraform provisioning, this can include:
      # AWS_ACCESS_KEY_ID
      # AWS_SECRET_ACCESS_KEY
      # AWS_DEFAULT_REGION
      #
      # The secure feature of minke can also be used to encrypt these values
      # with a private key.
      attr_accessor :environment
    end
  end
end
