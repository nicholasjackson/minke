require 'spec_helper'

describe Minke::Tasks::Task do
  let(:config) { double "config" }
  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }

  let(:task) do
    Minke::Tasks::Task.new config, docker_runner, logger
  end

  describe 'run_command_in_container' do
    it 'creates a container and runs a command with the correct parameters' do
      expect(docker_runner).to receive(:create_and_run_container)

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


end
