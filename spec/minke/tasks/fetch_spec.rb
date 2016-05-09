require 'spec_helper'

describe Minke::Tasks::Fetch do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.fetch = Minke::Config::Task.new
    end
  end

  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }
  let(:generator_settings) do
    Minke::Generators::GenerateSettings.new.tap do |g|
      g.command = Minke::Generators::BuildCommands.new.tap do |b|
        b.fetch = ['command1', 'command2']
      end
    end
  end

  let(:helper) do
    helper = double "helper"
    allow(helper).to receive(:invoke_task)
    allow(helper).to receive(:load_consul_data)
    allow(helper).to receive(:wait_for_HTTPOK)
    allow(helper).to receive(:copy_assets)
    return helper
  end

  let(:task) do
    Minke::Tasks::Fetch.new config, generator_settings, docker_runner, logger, helper
  end

  it 'executes the given commands in a container' do
    expect(docker_runner).to receive(:create_and_run_container).twice
    expect(docker_runner).to receive(:delete_container).twice

    task.run
  end

end
