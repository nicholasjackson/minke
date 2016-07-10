module Minke
  module Helpers
    class Error
      ##
      # fatal_error aborts the current execute with the given message
      def fatal_error message
        abort message
      end

    end
  end
end
