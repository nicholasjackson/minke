module Minke
  module Helpers
    class Logger

      def initialize writer, level=:normal
        @logger = writer
        @level = level
      end

      def log message, level
        ## implement logger implementation
        case level
        when :error
          @logger.error "#{DateTime.now.to_s}: #{message}"
        when :info
          @logger.info "#{DateTime.now.to_s}: #{message}"
        when :debug
          @logger.debug "#{DateTime.now.to_s}: #{message}" if @level == :verbose
        end
      end
    end
  end
end