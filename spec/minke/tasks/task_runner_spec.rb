require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Tasks::TaskRunner, :a => :b do

  let(:service_discovery) do
    sd = double('service_discovery')
    allow(sd).to receive(:public_address_for).and_return('0.0.0.0:8080')
    allow(sd).to receive(:bridge_address_for).and_return('172.156.23.1:8080')
    return sd
  end

  let(:runnerargs) do
    {
      :consul => consul,
      :docker_network => 'testing',
      :health_check => health_check,
      :rake_helper => rake_helper,
      :copy_helper => copy_helper,
      :service_discovery => service_discovery
    }
  end

  let(:task_runner) { Minke::Tasks::TaskRunner.new runnerargs }

  describe 'run_steps' do

    describe 'rake tasks' do
      it 'executes the defined rake tasks' do
        expect(rake_helper).to receive(:invoke_task).with('task1')

        task_runner.run_steps config.fetch.pre
      end 

      it 'executes both defined rake tasks' do
        expect(rake_helper).to receive(:invoke_task).twice

        task_runner.run_steps config.fetch.pre
      end
    end

    describe 'consul' do 
      it 'starts consul' do
        expect(true).to eq(false)
      end

      it 'waits for consul to start' do
        expect(true).to eq(false)
      end

      it 'stops consul at the end of the task' do
        expect(true).to eq(false)
      end

      it 'loads data into consul' do
        expect(consul).to receive(:load_consul_data).with('http://0.0.0.0:8080', 'myfile')

        task_runner.run_steps config.fetch.pre
      end

      it 'fetches the public address when executing health check' do
        expect(service_discovery).to receive(:public_address_for).with('myhealth', '8081')

        task_runner.run_steps config.fetch.pre
      end

      it 'fetches the bridge address when executing health check' do
        config.fetch.pre.health_check.type = 'bridge'
        ENV['DOCKER_NETWORK'] = 'tester'

        expect(service_discovery).to receive(:bridge_address_for).with('tester', 'myhealth', '8081')

        task_runner.run_steps config.fetch.pre
      end

      it 'replaces the ip address for the docker host if docker toolbox' do
        expect(health_check).to receive(:wait_for_HTTPOK).with('http://0.0.0.0:8080/v1/health', 0, 3)

        task_runner.run_steps config.fetch.pre
      end

      it 'waits for the health check to complete' do
        expect(health_check).to receive(:wait_for_HTTPOK).with('http://0.0.0.0:8080/v1/health', 0, 3)

        task_runner.run_steps config.fetch.pre
      end
    end

    describe 'copy assets' do
      it 'copies any assets' do
        expect(copy_helper).to receive(:copy_assets).with('/from1', './to1')

        task_runner.run_steps config.fetch.pre
      end

      it 'copies both assets' do
        expect(copy_helper).to receive(:copy_assets).twice

        task_runner.run_steps config.fetch.pre
      end
    end

  end

end