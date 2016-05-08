require 'docker'
require 'yaml'
require 'rest-client'
require 'consul_loader'
require 'rake'
require 'erb'
require 'resolv'
require 'logger'

require 'minke/version'

require 'minke/helpers/helper'

require 'minke/docker/docker_runner'
require 'minke/docker/docker_compose'

require 'minke/config/config'
require 'minke/config/reader'

require 'minke/tasks/task'
#require 'minke/tasks/build_image'
#require 'minke/tasks/build'
#require 'minke/tasks/cucumber'
#require 'minke/tasks/fetch'
#require 'minke/tasks/push'
#require 'minke/tasks/run'
#require 'minke/tasks/test'

require 'minke/generators/register'
require 'minke/generators/config'
require 'minke/generators/config_processor'
require 'minke/generators/config_variables'
