require 'spec_helper'

RSpec.shared_context 'shared context', :a => :b do

  let(:config) do
    Minke::Config::Config.new.tap do |c|
        c.application_name = "testapp"
        c.docker = Minke::Config::DockerSettings.new
        c.docker_registry = Minke::Config::DockerRegistrySettings.new.tap do |dr|
          dr.url = 'http://something'
          dr.user = 'myuser'
          dr.password = 'mypassword'
          dr.email = 'nic@dfgdf.com'
          dr.namespace = 'mynamespace'
        end
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

  let(:generator_config) do
    Minke::Generators::Config.new.tap do |c|
      c.build_settings = Minke::Generators::BuildSettings.new.tap do |bs|
        bs.build_commands = Minke::Generators::BuildCommands.new
        bs.docker_settings = Minke::Generators::DockerSettings.new
      end
    end
  end

  let(:task_runner) do
    runner = double('task_runner')
    allow(runner).to receive(:run_steps)
    return runner
  end

  let(:error_helper) do
    helper = double('error_helper')
    allow(helper).to receive(:fatal_error)
    return helper
  end

  let(:shell_helper) do
    helper = double('shell_helper')
    allow(helper).to receive(:execute)
    return helper
  end

  let(:logger_helper) do
    helper = double('logger_helper')
    allow(helper).to receive(:log)
    return helper
  end

  let(:consul) {  double('consul') }
  let(:health_check) { double('health_check') }
  let(:rake_helper) do
     helper = double('rake_helper')
     allow(helper).to receive(:invoke_task)
     return helper 
  end
  let(:copy_helper) { double('copy_helper') }

  let(:docker_compose) do
    compose = double('compose')
    allow(compose).to receive(:up)
    allow(compose).to receive(:down)
    allow(compose).to receive(:logs)
    return compose
  end

  let(:docker_compose_factory) do
    docker_compose_factory = double('docker_compose_factory')
    allow(docker_compose_factory).to receive(:create).and_return(docker_compose)
    return docker_compose_factory
  end

  let(:docker_runner) do
    runner = double('docker_runner')
    allow(runner).to receive(:create_and_run_container).and_return(nil, true)
    allow(runner).to receive(:delete_container)
    allow(runner).to receive(:get_docker_ip_address)
    allow(runner).to receive(:build_image)
    allow(runner).to receive(:login_registry)
    allow(runner).to receive(:tag_image)
    allow(runner).to receive(:push_image)
    return runner
  end

  let(:service_discovery) do
    sd = double('service_discovery')
    allow(sd).to receive(:public_address_for).and_return('0.0.0.0:8080')
    allow(sd).to receive(:bridge_address_for).and_return('172.156.23.1:8080')
    return sd
  end

  let(:args) do
    {
      :config => config,
      :generator_config => generator_config,
      :task_name => :fetch,
      :task_runner => task_runner,
      :error_helper => error_helper,
      :shell_helper => shell_helper,
      :logger_helper => logger_helper,
      :docker_compose_factory => docker_compose_factory,
      :docker_runner => docker_runner
    }
  end
end