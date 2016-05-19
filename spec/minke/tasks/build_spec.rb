require 'spec_helper'

describe Minke::Tasks::Build do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.build = Minke::Config::Task.new
    end
  end

  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }
  let(:generator_config) do
    Minke::Generators::Config.new.tap do |c|
      c.build_settings = Minke::Generators::BuildSettings.new.tap do |bs|
        bs.docker_settings = Minke::Generators::DockerSettings.new
        bs.build_commands = Minke::Generators::BuildCommands.new.tap do |b|
          b.build = ['command1', 'command2']
        end
      end
    end
  end
  let(:docker_compose_factory) { double "docker_compose_factory" }

  let(:helper) do
    helper = double "helper"
    allow(helper).to receive(:invoke_task)
    allow(helper).to receive(:load_consul_data)
    allow(helper).to receive(:wait_for_HTTPOK)
    allow(helper).to receive(:copy_assets)
    allow(helper).to receive(:fatal_error)
    return helper
  end

  let(:task) do
    Minke::Tasks::Build.new config, :build, generator_config, docker_runner, docker_compose_factory, logger, helper
  end

  it 'executes the given commands in a container' do
    expect(docker_runner).to receive(:create_and_run_container).twice
    expect(docker_runner).to receive(:delete_container).twice

    task.run
  end

end
