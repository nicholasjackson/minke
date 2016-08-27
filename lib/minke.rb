require 'consul_loader'
require 'docker'
require 'erb'
require 'fileutils'
require 'logger'
require 'rake'
require 'resolv'
require 'rest-client'
require 'rubygems'
require 'yaml'
require 'colorize'
require 'multi_json'
require 'openssl'
require 'base64'
require 'securerandom'
require 'sshkey'
require 'mkmf'

require 'minke/version'
require 'minke/command'

require 'minke/helpers/copy'
require 'minke/helpers/error'
require 'minke/helpers/rake'
require 'minke/helpers/shell'

require 'minke/docker/docker_compose'
require 'minke/docker/docker_runner'
require 'minke/docker/service_discovery'
require 'minke/docker/health_check'
require 'minke/docker/consul'
require 'minke/docker/network'

require 'minke/config/config'
require 'minke/config/reader'

require 'minke/tasks/task_runner'
require 'minke/tasks/task'
require 'minke/tasks/build'
require 'minke/tasks/bundle'
require 'minke/tasks/cucumber'
require 'minke/tasks/fetch'
require 'minke/tasks/push'
require 'minke/tasks/run'
require 'minke/tasks/test'
require 'minke/tasks/build_image'

require 'minke/generators/config'
require 'minke/generators/config_processor'
require 'minke/generators/config_variables'
require 'minke/generators/processor'
require 'minke/generators/register'
require 'minke/generators/shell_script'

require 'minke/encryption/encryption'
require 'minke/encryption/key_locator'

module Minke
  class Logging
    @@debug = false
    @@ret = "\n"
    
    def self.create_logger verbose = false
      Logger.new(STDOUT).tap do |l|
        l.datetime_format = ''
        l.formatter = proc do |severity, datetime, progname, msg|
          case severity
          when 'ERROR'
            s = "#{@@ret if @@debug}#{'ERROR'.colorize(:red)}: #{msg.chomp('')}\n"
            @@debug = false
            s
          when 'INFO'
            s = "#{@@ret if @@debug}#{'INFO'.colorize(:green)}: #{msg.chomp('')}\n"
            @@debug = false
            s
          when 'DEBUG'
            if verbose == true
              "#{'DEBUG'.colorize(:yellow)}: #{msg.chomp('')}\n"
            else
              @@debug = true
              "#{'.'.colorize(:yellow)}"
            end
          end
        end
      end
    end
  end
end