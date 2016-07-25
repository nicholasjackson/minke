module Minke
  module Tasks
    class Bundle < Task

      def run args = nil
        puts '### Install gems'
        rvm = "#{ENV['HOME']}/.rvm/scripts/rvm"
        rvm_root = '/usr/local/rvm/scripts/rvm'

        rvm_installed = @shell_helper.exist?(rvm)
        rvm_root_installed = @shell_helper.exist?(rvm_root)

        gemset = @shell_helper.read_file '.ruby-gemset'

        puts "Using gemset #{gemset}"

        rvm_command = "source #{rvm} && rvm gemset use #{gemset} --create && " if rvm_installed
        rvm_command = "source #{rvm_root} && rvm gemset use #{gemset} --create && " if rvm_root_installed

        puts "/bin/bash -c '#{rvm_command}bundle install -j3 && bundle update"

        @shell_helper.execute("/bin/bash -c '#{rvm_command}bundle install -j3 && bundle update'")
      end

    end
  end
end
