module Minke
  module Tasks
    class Push < Task

      def run
        puts "## Push image to registry"

        config = Minke::Helpers.config
      	Minke::GoDocker.tag_and_push config
      end

    end
  end
end
