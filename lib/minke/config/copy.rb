module Minke
  module Config
    ##
    # Copy defines a source and destination of either a file or directory to be copied during a task.
    class Copy
      ##
      # from is the file or directory to copy from.
      #
      # [Required]
      attr_accessor :from

      ##
      # to is the file or directory to copy to.
      #
      # [Required]
      attr_accessor :to
    end
  end
end
