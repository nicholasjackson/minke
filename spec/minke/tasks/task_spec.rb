require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Task, :a => :b do  
  let(:task) do
    Minke::Tasks::Task.new args  
  end

  describe 'run_command_in_container' do
    it 'creates a container and runs a command with the correct parameters' do
      config.fetch.docker.build_docker_file = nil
      expect(docker_runner).to receive(:find_image)
      expect(docker_runner).to receive(:pull_image)
      expect(docker_runner).to receive(:create_and_run_container)
      expect(docker_runner).to receive(:delete_container)

      task.run_command_in_container 'go build'
    end

    it 'builds a custom docker image when the docker_settings contains an override' do
      config.docker.build_docker_file = 'sdsdd'
      expect(docker_runner).to receive(:build_image)

      task.run_command_in_container config
    end

    it 'builds a custom docker image when the docker_settings contains an override' do
      config.fetch.docker.build_docker_file = 'sdsdd'
      expect(docker_runner).to receive(:build_image)

      task.run_command_in_container 'go build'
    end

    it 'set the correct custom docker image name when the docker_settings contains an override' do
      config.fetch.docker.build_docker_file = 'sdsdd'
      expect(docker_runner).to receive(:build_image).with('sdsdd', "testapp-buildimage")

      task.run_command_in_container 'go build'
    end

    it 'pulls the docker image when it does not exist' do
      config.fetch.docker.build_docker_file = nil
      expect(docker_runner).to receive(:find_image).with('buildimage').and_return(nil)
      expect(docker_runner).to receive(:pull_image).with('buildimage')

      task.run_command_in_container 'go build'
    end

    it 'does not the docker image when it exists' do
      config.fetch.docker.build_docker_file = nil
      expect(docker_runner).to receive(:find_image).with('buildimage').and_return(true)
      expect(docker_runner).to receive(:pull_image).with('buildimage').never

      task.run_command_in_container 'go build'
    end
  end

  describe 'run_with_block' do
    it 'creates a new network if one does not exist' do
      expect(docker_network).to receive(:create)
      task.run_with_block
    end

    it 'starts consul and loads data' do
      expect(consul).to receive(:start_and_load_data).with(config.fetch.consul_loader)
      task.run_with_block
    end

    it 'executes the pre steps' do
      expect(task_runner).to receive(:run_steps).with(config.fetch.pre)
      
      task.run_with_block
    end

    it 'executes the post steps' do
      expect(task_runner).to receive(:run_steps).with(config.fetch.post)

      task.run_with_block
    end

    it 'stops consul' do
      expect(consul).to receive(:stop)
      task.run_with_block
    end

    it 'removes a network if exists' do
      expect(docker_network).to receive(:remove)
      task.run_with_block
    end
  end

end