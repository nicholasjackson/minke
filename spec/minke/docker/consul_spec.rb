require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Docker::Consul, :a => :b do
  let(:network) { 'tester' }
  let(:consul_loader) do
    c = double('consul_loader')
    allow(c).to receive(:load_config)
    return c
  end
  let(:consul) { 
    Minke::Docker::Consul.new({
        :health_check => health_check, 
        :service_discovery => service_discovery, 
        :consul_loader => consul_loader, 
        :docker_runner => docker_runner, 
        :network => network, 
        :project_name => 'tester',
        :logger_helper => logger_helper
      }) 
    }
  
  describe 'consul' do 
    it 'starts consul' do
      args = {
        :image   => 'progrium/consul',
        :network => network,
        :command => '-server -bootstrap -ui-dir /ui',
        :name    => '/tester_consul_1',
        :deamon  => true
      }
      expect(docker_runner).to receive(:create_and_run_container).with(args)

      consul.start_and_load_data config.fetch.consul_loader 
    end

    it 'pulls the image when it does not exist' do
      allow(docker_runner).to receive(:find_image).and_return(nil)
      expect(docker_runner).to receive(:pull_image)

      consul.start_and_load_data config.fetch.consul_loader
    end

    it 'does not pulls the image when it exists' do
      allow(docker_runner).to receive(:find_image).and_return('dfdfdf')
      expect(docker_runner).to receive(:pull_image).never

      consul.start_and_load_data config.fetch.consul_loader
    end

    it 'waits for consul to start' do
      allow(service_discovery).to receive(:build_address).and_return('http://0.0.0.0:32667')
      expect(health_check).to receive(:wait_for_HTTPOK).with('http://0.0.0.0:32667/v1/status/leader')

      consul.start_and_load_data config.fetch.consul_loader
    end

    describe 'load data' do

      it 'loads data into consul' do
        allow(service_discovery).to receive(:build_address).and_return('http://0.0.0.0:32667')
        expect(consul_loader).to receive(:load_config).with('myfile', 'http://0.0.0.0:32667')
        
        consul.start_and_load_data config.fetch.consul_loader
      end

      it 'fetches the public address when executing health check' do
        expect(service_discovery).to receive(:build_address).with(config.fetch.consul_loader.url)

        consul.start_and_load_data config.fetch.consul_loader
      end

      it 'waits for the health check to complete' do
        expect(health_check).to receive(:wait_for_HTTPOK)

        consul.start_and_load_data config.fetch.consul_loader
      end
    end

    it 'stops the consul container' do
      expect(docker_runner).to receive(:stop_container)

      consul.start_and_load_data config.fetch.consul_loader
      consul.stop
    end

    it 'deletes container' do
      
      expect(docker_runner).to receive(:delete_container)

      consul.start_and_load_data config.fetch.consul_loader
      consul.stop
    end

    it 'does not stop the consul container if the container is not running' do
      allow(docker_runner).to receive(:create_and_run_container).and_return([nil, false])
      expect(docker_runner).to receive(:stop_container).never()

      consul.start_and_load_data config.fetch.consul_loader
      consul.stop
    end

    it 'does not delete the consul container if the container is not running' do
      allow(docker_runner).to receive(:create_and_run_container).and_return([nil, false])
      expect(docker_runner).to receive(:delete_container).never()

      consul.start_and_load_data config.fetch.consul_loader
      consul.stop
    end
  end
end

      # it 'replaces the ip address for the docker host if docker toolbox' do
      #   expect(health_check).to receive(:wait_for_HTTPOK).with('http://0.0.0.0:8080/v1/health', 0, 3)

      #   task_runner.run_steps config.fetch.pre
      # end

      # it 'fetches the bridge address when executing health check' do
      #   config.fetch.pre.health_check.type = 'bridge'
      #   ENV['DOCKER_NETWORK'] = 'tester'

      #   expect(service_discovery).to receive(:bridge_address_for).with('tester', 'myhealth', '8081')

      #   task_runner.run_steps config.fetch.pre
      # end