require 'spec_helper'

describe Minke::Tasks::BuildImage do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = 'testapp'
      c.docker = Minke::Config::DockerSettings.new.tap do |d|
        d.application_docker_file = './docker'
      end
      c.build = Minke::Config::Task.new
    end
  end

  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }
  let(:generator_config) do
    Minke::Generators::Config.new.tap do |c|
      c.build_settings = Minke::Generators::BuildSettings.new.tap do |bs|
        bs.docker_settings = Minke::Generators::DockerSettings.new
      end
    end
  end
  let(:docker_compose_factory) { double "docker_compose_factory" }

  let(:service_discovery) { double "service_discovery" }

  let(:helper) do
    helper = double "helper"
    allow(helper).to receive(:invoke_task)
    allow(helper).to receive(:load_consul_data)
    allow(helper).to receive(:wait_for_HTTPOK)
    allow(helper).to receive(:copy_assets)
    allow(helper).to receive(:fatal_error)
    return helper
  end

  let(:system_runner) do
    runner = double 'system_runner'
    allow(runner).to receive(:execute)
    return runner
  end

  let(:task) do
    Minke::Tasks::BuildImage.new config, :build, generator_config, docker_runner, docker_compose_factory, service_discovery, logger, helper, system_runner
  end

  it 'builds an image from the dockerfile' do
    expect(docker_runner).to receive(:build_image).with('./docker', 'testapp')

    task.run
  end

end
