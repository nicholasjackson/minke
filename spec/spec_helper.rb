$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

#require "simplecov"
#SimpleCov.minimum_coverage 80
#SimpleCov.start

require 'webmock/rspec'
require 'minke'

WebMock.disable_net_connect!(:allow => "codeclimate.com")

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
