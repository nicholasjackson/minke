module Minke
  module Tasks
    class Bundle

      def initialize args
        @shell_helper = args[:shell_helper]
        @logger = args[:logger_helper]
      end

      def run args = nil
        @logger.info '### Install gems'

        @shell_helper.execute('bundle install')
      end

    end
  end
end
