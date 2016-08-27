module Minke
  module Tasks
    class Bundle

      def initialize args
        @shell_helper = args[:shell_helper]
        @logger = args[:logger_helper]
      end

      def run args = nil
        @logger.info '### Install gems'
        rvm = "#{ENV['HOME']}/.rvm/scripts/rvm"
        rvm_root = '/usr/local/rvm/scripts/rvm'

        rvm_installed = @shell_helper.exist?(rvm)
        rvm_root_installed = @shell_helper.exist?(rvm_root)

        gemset = @shell_helper.read_file '.ruby-gemset'

        @logger.info "Using gemset #{gemset}"

        rvm_command = "source #{rvm} && rvm gemset use #{gemset} --create && " if rvm_installed
        rvm_command = "source #{rvm_root} && rvm gemset use #{gemset} --create && " if rvm_root_installed

        @shell_helper.execute("/bin/bash -c '#{rvm_command}bundle install -j3 && bundle update'")
      end

    end
  end
end
