module Minke
  module Docker
    class SystemRunner

      def execute command
        system("#{command}")
      end

    end
  end
end
