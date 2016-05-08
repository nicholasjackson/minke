module Minke
  module Tasks
    class Fetch < Task

      def run
        if config[:build_config][:build][:get] != nil
          puts "## Get dependent packages"

          config[:build_config][:build][:get].each do |command|
          	run_command_in_container command
          end

          puts ""
        end
      end

    end
  end
end
