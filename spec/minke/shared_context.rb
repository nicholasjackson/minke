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
        c.build = Minke::Config::Task.new
        c.test = Minke::Config::Task.new
        c.cucumber = Minke::Config::Task.new
        c.shell = Minke::Config::Task.new
        c.fetch = Minke::Config::Task.new.tap do |f|
          f.ports = [':8080']
          f.consul_loader = Minke::Config::ConsulLoader.new.tap do |cl|
            cl.url = Minke::Config::URL.new.tap do |u|
              u.address = 'myfile'
              u.port = '8080'
              u.protocol = 'http'
              u.type = 'public'
            end
            cl.config_file = 'myfile'
          end
          f.health_check = Minke::Config::URL.new.tap do |u|
            u.address = 'myhealth'
            u.port = '8081'
            u.path = '/v1/health'
            u.protocol = 'http'
            u.type = 'public'
          end
          f.docker = Minke::Config::DockerSettings.new.tap do |d|
            d.application_compose_file = './compose_file'
            d.build_image = 'buildimage'
            d.build_docker_file = './docker_file'
          end
          f.pre = Minke::Config::TaskRunSettings.new.tap do |p|
            p.tasks = ['task1', 'task2']
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
        bs.docker_settings = Minke::Generators::DockerSettings.new.tap do |ds| 
          ds.working_directory = '/working'
        end
      end
    end
  end

  let(:task_runner) do
    runner = double('task_runner')
    allow(runner).to receive(:run_steps)
    return runner
  end

  let(:shell_helper) do
    helper = double('shell_helper')
    allow(helper).to receive(:execute)
    allow(helper).to receive(:exist?)
    allow(helper).to receive(:read_file)
    return helper
  end

  let(:logger_helper) do
    helper = double('logger_helper')
    allow(helper).to receive(:info)
    allow(helper).to receive(:debug)
    allow(helper).to receive(:error)
    return helper
  end

  let(:consul) do
    c = double('consul')
    allow(c).to receive(:start_and_load_data)
    allow(c).to receive(:stop)
    return c
  end

  let(:health_check) do
    health = double('health_check')
    allow(health).to receive(:wait_for_HTTPOK)
    return health 
  end
  
  let(:ruby_helper) do
     helper = double('ruby_helper')
     allow(helper).to receive(:invoke_task)
     return helper 
  end
  
  let(:copy_helper) do 
    copy = double('copy_helper')
    allow(copy).to receive(:copy_assets)
    return copy
  end

  let(:docker_compose) do
    compose = double('compose')
    allow(compose).to receive(:up)
    allow(compose).to receive(:down)
    allow(compose).to receive(:logs)
    allow(compose).to receive(:services)

    return compose
  end

  let(:docker_compose_factory) do
    docker_compose_factory = double('docker_compose_factory')
    allow(docker_compose_factory).to receive(:create).and_return(docker_compose)
    return docker_compose_factory
  end

  let(:docker_runner) do
    runner = double('docker_runner')
    allow(runner).to receive(:create_and_run_container).and_return([true, true])
    allow(runner).to receive(:create_and_run_blocking_container).and_return([true, true])
    allow(runner).to receive(:delete_container)
    allow(runner).to receive(:get_docker_ip_address)
    allow(runner).to receive(:build_image)
    allow(runner).to receive(:login_registry)
    allow(runner).to receive(:tag_image)
    allow(runner).to receive(:push_image)
    allow(runner).to receive(:find_image)
    allow(runner).to receive(:pull_image)
    allow(runner).to receive(:stop_container)
    return runner
  end

  let(:service_discovery) do
    sd = double('service_discovery')
    allow(sd).to receive(:public_address_for).and_return('0.0.0.0:8080')
    allow(sd).to receive(:bridge_address_for).and_return('172.156.23.1:8080')
    allow(sd).to receive(:build_address)
    return sd
  end

  let(:docker_network) do
    dn = double('docker_network')
    allow(dn).to receive(:create)
    allow(dn).to receive(:remove)
    return dn
  end

  let(:args) do
    {
      :config => config,
      :generator_config => generator_config,
      :task_name => :fetch,
      :task_runner => task_runner,
      :shell_helper => shell_helper,
      :logger_helper => logger_helper,
      :docker_compose_factory => docker_compose_factory,
      :docker_runner => docker_runner,
      :consul => consul,
      :docker_network => docker_network,
      :health_check => health_check,
      :service_discovery => service_discovery
    }
  end
end
