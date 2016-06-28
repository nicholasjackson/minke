module Minke
  module Tasks
    class Fetch < Task

      def run args = nil
        puts "## Update dependencies"

        puts '### Install gems'
        @system_runner.execute('bundle install -j3 && bundle update')

        puts '### Install generator dependencies'
        run_with_block do
          if @generator_settings.build_settings.build_commands.fetch != nil
            @generator_settings.build_settings.build_commands.fetch.each do |command|
              run_command_in_container command
            end
          end
        end
      end

    end
  end
end
