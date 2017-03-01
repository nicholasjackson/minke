require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Command, :a => :b do

  let(:command) do
    command = Minke::Command.new(config, generator_config, logger_helper)
    allow(command).to receive(:create_tasks).and_return(tasks)
    command
  end

  let(:tasks) do
    {
      :bundler        => double("bundler").tap { |d| allow(d).to receive(:run) },
      :fetch          => double("fetch").tap { |d| allow(d).to receive(:run) },
      :build          => double("build").tap { |d| allow(d).to receive(:run) },
      :test           => double("test").tap { |d| allow(d).to receive(:run) },
      :build_image    => double("build_image").tap { |d| allow(d).to receive(:run) },
      :cucumber       => double("cucumber").tap { |d| allow(d).to receive(:run) },
      :push           => double("push").tap { |d| allow(d).to receive(:run) }
    }
  end

  it 'creates all the dependencies' do
    deps = command.create_dependencies :fetch

    deps.each { |dep| expect(dep).to_not be_nil() }
  end

  describe 'fetch' do
    it 'runs the fetch task' do
      expect(tasks[:fetch]).to receive(:run).once
      command.fetch
    end

    it 'does not run the fetch task when there is no config' do
      command.config.fetch = nil
      expect(tasks[:fetch]).to receive(:run).never
      command.fetch
    end
  end

  describe 'build' do
    it 'runs the fetch task' do
      expect(tasks[:fetch]).to receive(:run).once
      command.build
    end

    it 'runs the build task' do
      expect(tasks[:build]).to receive(:run).once
      command.build
    end

    it 'does not run the fetch task when there is no config' do
      command.config.build = nil
      expect(tasks[:build]).to receive(:run).never
      command.build
    end
  end

  describe 'test' do
    it 'runs the build task' do
      expect(tasks[:build]).to receive(:run).once
      command.test
    end

    it 'runs the test task' do
      expect(tasks[:test]).to receive(:run).once
      command.test
    end

    it 'does not run the fetch task when there is no config' do
      command.config.test = nil
      expect(tasks[:build]).to receive(:run).never
      command.test
    end
  end

  describe 'build_image' do
    it 'runs the test task' do
      expect(tasks[:test]).to receive(:run).once
      command.build_image
    end

    it 'runs the build_image task' do
      expect(tasks[:build_image]).to receive(:run).once
      command.build_image
    end

    it 'does not run the build_image task when there is no config' do
      command.config.test = nil
      expect(tasks[:build_image]).to receive(:run).never
      command.build_image
    end
  end

  describe 'cucumber' do
    it 'runs the cucumber task' do
      expect(tasks[:cucumber]).to receive(:run).once
      command.cucumber
    end

    it 'does not run the cucumber task when there is no config' do
      command.config.cucumber = nil
      expect(tasks[:cucumber]).to receive(:run).never
      command.cucumber
    end
  end

  describe 'push' do
    it 'runs the push task' do
      expect(tasks[:push]).to receive(:run).once
      command.push
    end
  end

  describe 'shell' do
    it 'runs the shell task' do
      expect(tasks[:shell]).to receive(:shell).once
      command.shell
    end
  end
end
