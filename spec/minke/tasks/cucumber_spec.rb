require 'spec_helper'

describe Minke::Tasks::Cucumber do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.cucumber = Minke::Config::Task.new
    end
  end

  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }
  let(:generator_settings) do
    Minke::Generators::Config.new.tap do |c|
      #c.command = Minke::Generators::BuildCommands.new
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
    Minke::Tasks::Cucumber.new config, config.cucumber, generator_settings, docker_runner, docker_compose_factory, logger, helper
  end

  it 'calls create on the compose factory' do
    expect(docker_compose_factory).to receive(:create)

    task.run
  end

  it 'starts the compose stack' do
    expect(docker_compose).to receive(:up)

    task.run
  end

  it 'executes the cucumber shell' do
    expect(helper).to receive(:execute_shell_command)

    task.run
  end

  it 'stops copose and removes containers' do
    expect(docker_compose).to receive(:stop)
    expect(docker_compose).to receive(:rm)

    task.run
  end

  it 'throws a fatal error when status from the executed command is 1' do
    expect(helper).to receive(:fatal_error)

    task.run
  end

  it 'does not throw a fatal error when status from the executed command is 0' do
    allow(helper).to receive(:execute_shell_command).and_return(0)
    expect(helper).to_not receive(:fatal_error)

    task.run
  end

end
