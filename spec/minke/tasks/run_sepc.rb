require 'spec_helper'

describe Minke::Tasks::Run do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.run = Minke::Config::Task.new
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

  let(:docker_compose) do
    dc = double "docker_compose"
    allow(dc).to receive(:stop)
    allow(dc).to receive(:up)
    allow(dc).to receive(:rm)
    return dc
  end

  let(:docker_compose_factory) do
     dc = double("docker_compose_factory")
     allow(dc).to receive(:create).and_return(docker_compose)
     return dc
   end

  let(:helper) do
    helper = double "helper"
    allow(helper).to receive(:invoke_task)
    allow(helper).to receive(:load_consul_data)
    allow(helper).to receive(:wait_for_HTTPOK)
    allow(helper).to receive(:copy_assets)
    allow(helper).to receive(:execute_shell_command)
    allow(helper).to receive(:fatal_error)
    return helper
  end

  let(:task) do
    Minke::Tasks::Run.new config, config.run, generator_config, docker_runner, docker_compose_factory, logger, helper
  end

  it 'calls create on the compose factory' do
    expect(docker_compose_factory).to receive(:create)

    task.run
  end

  it 'starts the compose stack' do
    expect(docker_compose).to receive(:up)

    task.run
  end

  it 'spools the compose logs' do
    expect(docker_compose).to receive(:logs)

    task.run
  end

  it 'stops copose and removes containers' do
    expect(docker_compose).to receive(:down)

    task.run
  end
end
