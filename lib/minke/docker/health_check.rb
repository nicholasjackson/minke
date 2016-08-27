module Minke
  module Docker
    ##
    # HealthCheck checks health of a running container
    class HealthCheck

      def initialize logger, count=nil, pause=nil
        @count = count ||= 180
        @pause = pause ||= 1
        @successes = 2
        @logger = logger
      end

      ##
      # waits until a 200 response is received from the given url
      def wait_for_HTTPOK url
        @logger.debug "Waiting for server #{url} to start #{@count} attempts left"

        begin
          response = RestClient.send('get', url)
        rescue
          @logger.error 'Invalid response from server'
        end

        check_response response, url
      end

      private
      def check_response response, url
        if response == nil || !response.code.to_i == 200
          check_failed url
        else
          check_success url
        end
      end

      def check_failed url
        @count -= 1
        sleep @pause

        if @count > 0
          wait_for_HTTPOK url
        else
          raise 'Server failed to start'
        end
      end

      def check_success url
        if @successes > 0 
          @logger.debug "Server: #{url} passed health check, #{@successes} checks to go..."

          @successes -= 1
          sleep @pause
          wait_for_HTTPOK url
        else
          @logger.debug "Server: #{url} healthy"
        end
      end

    end
  end
end
