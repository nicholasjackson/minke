require 'spec_helper'

describe Minke::Docker::HealthCheck do

  let(:url) { 'http://something/v1' }
  let(:healthcheck) { Minke::Docker::HealthCheck.new url, 10, 0 }

  it 'calls the given url and returns when url is accessible' do
    stub_request(:any, url)

    healthcheck.wait_for_HTTPOK

    expect(a_request(:any, url)).to have_been_made.times(3)
  end

  it 'retries the given url 10 times when the url does not return 200' do
    stub_request(:any, url).to_timeout

    begin
      healthcheck.wait_for_HTTPOK
    rescue
    
    end

    expect(a_request(:any, url)).to have_been_made.times(10)
  end

  it 'rases an exception when the url does not return 200 after 10 attempts' do
    stub_request(:any, url).to_timeout

    expect { healthcheck.wait_for_HTTPOK }.to raise_error('Server failed to start')
  end

end