module Minke
  module Config
   
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

      ##
      # terraform contains the an instance of Minke::Config::TerraformSettings which
      # contains the details for the terraform provisioning section.
      attr_accessor :terraform
    end
  end
end
