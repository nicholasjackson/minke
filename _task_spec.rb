require 'spec_helper'
/*
describe Minke::Tasks::Task do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.application_name = "testapp"
      c.docker = Minke::Config::DockerSettings.new
      c.fetch = Minke::Config::Task.new.tap do |f|
        f.docker = Minke::Config::DockerSettings.new.tap do |d|
          d.application_compose_file = './compose_file'
          d.build_image = 'buildimage'
          d.build_docker_file = './docker_file'
        end
        f.pre = Minke::Config::TaskRunSettings.new.tap do |p|
          p.tasks = ['task1', 'task2']
          p.consul_loader = Minke::Config::ConsulLoader.new.tap do |cl|
            cl.url = Minke::Config::URL.new.tap do |u|
              u.address = 'myfile'
              u.port = '8080'
              u.protocol = 'http'
              u.type = 'public'
            end
            cl.config_file = 'myfile'
          end
          p.health_check = Minke::Config::URL.new.tap do |u|
            u.address = 'myhealth'
            u.port = '8081'
            u.path = '/v1/health'
            u.protocol = 'http'
            u.type = 'public'
          end
          p.copy = [
            Minke::Config::Copy.new.tap { |cp| cp.from = '/from1'; cp.to = './to1'},
            Minke::Config::Copy.new.tap { |cp| cp.from = '/from2'; cp.to = './to2'}
          ]
        end
        f.post = Minke::Config::TaskRunSettings.new.tap do |p|
          p.tasks = ['task3', 'task4']
        end
      end
    end
  end

  let(:docker_runner) do
    runner = double "docker_runner"
    allow(runner).to receive(:create_and_run_container).and_return(nil, true)
    allow(runner).to receive(:delete_container)
    allow(runner).to receive(:get_docker_ip_address)
    return runner
  end
  let(:logger) { double "logger" }
  let(:generator_config) do
    Minke::Generators::Config.new.tap do |c|
      c.build_settings = Minke::Generators::BuildSettings.new.tap do |bs|
        bs.docker_settings = Minke::Generators::DockerSettings.new
      end
    end
  end

  let(:compose) do
    double "compose"
  end

  let(:docker_compose_factory) do
    dc = double "docker_compose_factory"
    expect(dc).to receive(:create).and_return(compose)
    dc
  end

  let(:service_discovery) do
    sd = double "service_discovery"
    allow(sd).to receive(:public_address_for).and_return('0.0.0.0:8080')
    allow(sd).to receive(:bridge_address_for).and_return('172.156.23.1:8080')
    sd
  end

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
    Minke::Tasks::Task.new config, :fetch, generator_config, docker_runner, docker_compose_factory, service_discovery, logger, helper, system_runner
  end

  describe 'run_command_in_container' do
    it 'creates a container and runs a command with the correct parameters' do
      config.fetch.docker.build_docker_file = nil
      expect(docker_runner).to receive(:find_image)
      expect(docker_runner).to receive(:pull_image)
      expect(docker_runner).to receive(:create_and_run_container)
      expect(docker_runner).to receive(:delete_container)

      task.run_command_in_container config
    end

    it 'builds a custom docker image when the docker_settings contains an override' do
      config.docker.build_docker_file = './sdsdd'
      expect(docker_runner).to receive(:build_image)

      task.run_command_in_container config
    end

    it 'builds a custom docker image when the docker_settings contains an override' do
      config.fetch.docker.build_docker_file = './sdsdd'
      expect(docker_runner).to receive(:build_image)

      task.run_command_in_container config
    end

    it 'set the correct custom docker image name when the docker_settings contains an override' do
      config.fetch.docker.build_docker_file = './sdsdd'
      expect(docker_runner).to receive(:build_image).with('./sdsdd', "testapp-buildimage")

      task.run_command_in_container config
    end

    it 'pulls the docker image when it does not exist' do
      config.fetch.docker.build_docker_file = nil
      expect(docker_runner).to receive(:find_image).with('buildimage').and_return(nil)
      expect(docker_runner).to receive(:pull_image).with('buildimage')

      task.run_command_in_container config
    end

    it 'does not the docker image when it exists' do
      config.fetch.docker.build_docker_file = nil
      expect(docker_runner).to receive(:find_image).with('buildimage').and_return(true)
      expect(docker_runner).to receive(:pull_image).with('buildimage').never

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
    it 'executes the pre steps' do
      expect(helper).to receive(:invoke_task).with('task1')

      task.run_with_block
    end

    it 'executes the post steps' do
      expect(helper).to receive(:invoke_task).with('task3')

      task.run_with_block
    end
  end

  describe 'run_steps' do
    it 'executes the defined rake tasks' do
      expect(helper).to receive(:invoke_task).with('task1')

      task.run_steps config.fetch.pre
    end

    it 'executes both defined rake tasks' do
      expect(helper).to receive(:invoke_task).twice

      task.run_steps config.fetch.pre
    end

    it 'starts consul' do
      expect(true).to eq(false)
    end

    it 'waits for consul to start' do
      expect(true).to eq(false)
    end

    it 'loads data into consul' do
      expect(helper).to receive(:load_consul_data).with('http://0.0.0.0:8080', 'myfile')

      task.run_steps config.fetch.pre
    end

    it 'fetches the public address when executing health check' do
      expect(service_discovery).to receive(:public_address_for).with('myhealth', '8081')

      task.run_steps config.fetch.pre
    end

    it 'fetches the bridge address when executing health check' do
      config.fetch.pre.health_check.type = 'bridge'
      ENV['DOCKER_NETWORK'] = 'tester'

      expect(service_discovery).to receive(:bridge_address_for).with('tester', 'myhealth', '8081')

      task.run_steps config.fetch.pre
    end

    it 'replaces the ip address for the docker host if docker toolbox' do
      expect(helper).to receive(:wait_for_HTTPOK).with('http://0.0.0.0:8080/v1/health', 0, 3)

      task.run_steps config.fetch.pre
    end

    it 'waits for the health check to complete' do
      expect(helper).to receive(:wait_for_HTTPOK).with('http://0.0.0.0:8080/v1/health', 0, 3)

      task.run_steps config.fetch.pre
    end

    it 'copies any assets' do
      expect(helper).to receive(:copy_assets).with('/from1', './to1')

      task.run_steps config.fetch.pre
    end

    it 'copies both assets' do
      expect(helper).to receive(:copy_assets).twice

      task.run_steps config.fetch.pre
    end

    it 'stops consul' do
      expect(true).to eq(false)
    end
  end

end
*/