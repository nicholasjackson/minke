module Minke
  module Tasks
    class Fetch < Task

      def run args = nil
        puts "## Update dependencies"

        puts '### Install gems'
        rvm = "#{ENV['HOME']}/.rvm/scripts/rvm"
        rvm_installed = File.exist?(rvm)
        rvm_command = "source #{rvm} && " if rvm_installed 

        @shell_helper.execute("#{rvm_command}bundle install -j3 && bundle update")

        puts '### Install generator dependencies'
        
        if @generator_config.build_settings.build_commands.fetch != nil
          run_with_block do
            @generator_config.build_settings.build_commands.fetch.each do |command|
              run_command_in_container command
            end
          end
        end
      end

    end
  end
end
