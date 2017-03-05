require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Shell, :a => :b do
  let(:services) do
    YAML.load(<<-EOF
---
version: '2'
services:
  test2:
    image: test2
    ports:
    - "::8001"
    environment:
    - CONSUL=consul:8500
    links:
    - statsd:statsd
    external_links:
    - tester_consul_1:consul
  statsd:
    image: hopsoft/graphite-statsd:latest
    ports:
    - "::80"
    expose:
    - 8125/udp
    environment:
    - SERVICE_NAME=statsd
    external_links:
    - tester_consul_1:consul
networks:
  default:
    external:
      name: tester
EOF
    )

  end
  let(:task) do
    allow(docker_compose).to receive(:services).and_return(services['services'])
    Minke::Tasks::Shell.new args
  end

  it 'starts the compose stack' do
    expect(docker_compose).to receive(:up)

    task.run
  end

  it 'gets a list of services from compose' do
    expect(docker_compose).to receive(:services)

    task.run
  end

  it 'stops compose and removes containers' do
    expect(docker_compose).to receive(:down)

    task.run
  end

  it 'logs the shell starting message' do
    expect(logger_helper).to receive(:info).with("## Shell open to build container")
    
    task.run
  end

  it 'starts a shell in the build container' do
    expect(docker_runner).to receive(:create_and_run_blocking_container).once.with(hash_including(        
      :image => 'testapp-buildimage',
      :working_directory => '/working',
      :links => ['test2','statsd', 'consul'],
      :volumes => nil,
      :command => ['/bin/sh','-c','ls && /bin/sh'],
      :ports => [':8080']))
    
    task.run
  end
end

