module Minke
  module Tasks
    class Run < Task

      def run args = nil
        puts "## Run application with docker compose"

      	begin
          @compose.up

          run_with_block do
            @compose.logs
          end

      	ensure
      		@compose.down
      	end
      end

    end
  end
end
