module Minke
  module Helpers
    class Ruby
     
      def initialize
        load_ruby_files
      end

      def load_ruby_files
        $LOAD_PATH.unshift Dir.pwd
        Dir[File.join(Dir.pwd, "*.rb")].each {|file| require File.basename(file) }
      end

      ##
      # invoke a rake task
      def invoke_task(task, logger)
        Minke::Extension.new(logger).send(task)
      end
    end
  end
end
