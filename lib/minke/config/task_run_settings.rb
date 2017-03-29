module Minke
  module Config
    ##
    # TaskRunSettings encapsulates the configuration for the various pre and post sections for each task.
    # You can use this section to load config into consul, wait for a health check to complete, copy files
    # or execute other tasks defined in your Rakefile.
    class TaskRunSettings
      ##
      # tasks is an array of strings which point to a defined task in your Rakefile.
      #
      # [Optional]
      attr_accessor :tasks

      ##
      # copy is an array of Copy instances which will be copied before the task continues.
      # instance of Minke::Config::Copy
      #
      # [Optional]
      attr_accessor :copy
    end
  end
end
