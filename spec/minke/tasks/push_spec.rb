require 'spec_helper'

describe Minke::Tasks::Push do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.docker_registry = Minke::Config::DockerRegistrySettings.new.tap do |d|
        d.url = 'url'
        d.user = 'user'
        d.password = 'password'
        d.email = 'email'
        d.namespace = 'namespace'
      end
      c.run = Minke::Config::Task.new
    end
  end

  let(:docker_runner) do
    runner = double 'docker_runner'
    allow(runner).to receive(:login_registry)
    allow(runner).to receive(:tag_image)
    allow(runner).to receive(:push_image)
    return runner
  end
  let(:logger) { double 'logger' }
  let(:generator_config) do
    Minke::Generators::Config.new.tap do |c|
      c.build_settings = Minke::Generators::BuildSettings.new.tap do |bs|
        bs.docker_settings = Minke::Generators::DockerSettings.new
      end
    end
  end

  let(:task) do
    Minke::Tasks::Push.new config, config.run, generator_config, docker_runner, nil, logger, nil
  end

  it 'logs into the registry' do
    expect(docker_runner).to receive(:login_registry).with('url', 'user', 'password', 'email')

    task.run
  end

  it 'logs into the registry' do
    expect(docker_runner).to receive(:tag_image).with('testapp', 'namespace/testapp')

    task.run
  end

  it 'tags the image' do
    expect(docker_runner).to receive(:push_image).with('namespace/testapp')

    task.run
  end

end
