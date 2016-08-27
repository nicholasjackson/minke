require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Docker::HealthCheck, :a => :b do  

  let(:url) { 'http://something/v1' }
  
  let(:healthcheck) { Minke::Docker::HealthCheck.new logger_helper, 10, 0 }

  it 'calls the given url and returns when url is accessible' do
    stub_request(:any, url)

    healthcheck.wait_for_HTTPOK url

    expect(a_request(:any, url)).to have_been_made.times(3)
  end

  it 'retries the given url 10 times when the url does not return 200' do
    stub_request(:any, url).to_timeout

    begin
      healthcheck.wait_for_HTTPOK url
    rescue
    
    end

    expect(a_request(:any, url)).to have_been_made.times(10)
  end

  it 'rases an exception when the url does not return 200 after 10 attempts' do
    stub_request(:any, url).to_timeout

    expect { healthcheck.wait_for_HTTPOK url }.to raise_error('Server failed to start')
  end

end