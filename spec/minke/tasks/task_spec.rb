require 'spec_helper'

describe Minke::Tasks::Task do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.fetch = Minke::Config::Task.new.tap do |f|
        f.docker = Minke::Config::DockerSettings.new
        f.pre = Minke::Config::TaskRunSettings.new.tap do |p|
          p.tasks = ['task1', 'task2']
          p.consul_loader = Minke::Config::ConsulLoader.new.tap do |cl|
            cl.url = 'myurl'
            cl.config_file = 'myfile'
          end
        end
      end
    end
  end

  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }
  let(:generator_settings) { double "generator_settings" }

  let(:helper) do
    helper = double "helper"
    allow(helper).to receive(:invoke_task)
    allow(helper).to receive(:load_consul_data)
    return helper
  end

  let(:task) do
    Minke::Tasks::Task.new config, generator_settings, docker_runner, logger, helper
  end

  describe 'run_command_in_container' do
    it 'creates a container and runs a command with the correct parameters' do
      expect(docker_runner).to receive(:create_and_run_container)
      expect(docker_runner).to receive(:delete_container)

      task.run_command_in_container config
    end
  end

  describe 'log' do
    it 'calls the logger.error when level is :error' do
      message = 'a message'
      expect(logger).to receive(:error).with(message)

      task.log 'a message', :error
    end

    it 'calls the logger.error when level is :info' do
      message = 'a message'
      expect(logger).to receive(:info).with(message)

      task.log 'a message', :info
    end

    it 'calls the logger.error when level is :debug' do
      message = 'a message'
      expect(logger).to receive(:debug).with(message)

      task.log 'a message', :debug
    end
  end

  describe 'run_with_config' do
    it 'builds a custom docker image when the docker_settings contains an override' do
      config.docker.build_docker_file = './sdsdd'
      expect(docker_runner).to receive(:build_image)

      task.run_with_config config, config.fetch
    end

    it 'builds a custom docker image when the docker_settings contains an override' do
      config.fetch.docker.build_docker_file = './sdsdd'
      expect(docker_runner).to receive(:build_image)

      task.run_with_config config, config.fetch
    end

    it 'set the correct custom docker image name when the docker_settings contains an override' do
      config.fetch.docker.build_docker_file = './sdsdd'
      expect(docker_runner).to receive(:build_image).with('./sdsdd', "testapp-buildimage")

      task.run_with_config config, config.fetch
    end
  end

  describe 'run_steps' do
    it 'executes the defined rake tasks' do
      expect(helper).to receive(:invoke_task).twice

      task.run_steps config.fetch.pre
    end

    it 'loads data into consul' do
      expect(helper).to receive(:load_consul_data).with('myurl', 'myfile')

      task.run_steps config.fetch.pre
    end
  end

end
