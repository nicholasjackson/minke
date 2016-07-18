module Minke
  module Helpers
    class Logger
      def log message, level
        ## implement logger implementation
        case level
        when :error
          @logger.error message
        when :info
          @logger.info message
        when :debug
          @logger.debug message
        end
      end
    end
  end
end