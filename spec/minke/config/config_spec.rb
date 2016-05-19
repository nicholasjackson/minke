require 'spec_helper'

describe Minke::Config::Config do
  let(:config) do
    Minke::Config::Config.new.tap do |c|
      c.docker = Minke::Config::DockerSettings.new
      c.docker.application_compose_file = './compose.default.yml'
      c.docker.build_image = 'default'
      c.docker.build_docker_file = './mydefault'
    end
  end

  let(:task) do
    Minke::Config::Task.new.tap do |c|
      c.docker = Minke::Config::DockerSettings.new
    end
  end

  it 'correctly returns the overriden compose file for the fetch section' do
    task.docker.application_compose_file = './compose/fetch.yaml'
    config.fetch = task

    expect(config.compose_file_for :fetch).to eq(task.docker.application_compose_file)
  end

  it 'correctly returns the default compose file when the fetch section does not override' do
    config.fetch = task

    expect(config.compose_file_for :fetch).to eq(config.docker.application_compose_file)
  end

  it 'correctly returns the overriden build_image for the fetch section' do
    task.docker.build_image = 'myimage'
    config.fetch = task

    expect(config.build_image_for :fetch).to eq(task.docker.build_image)
  end

  it 'correctly returns the default compose file when the fetch section does not override' do
    config.fetch = task

    expect(config.build_image_for :fetch).to eq(config.docker.build_image)
  end

  it 'correctly returns the overriden build_image for the fetch section' do
    task.docker.build_docker_file = './myfile'
    config.fetch = task

    expect(config.build_docker_file_for :fetch).to eq(task.docker.build_docker_file)
  end

  it 'correctly returns the default compose file when the fetch section does not override' do
    config.fetch = task

    expect(config.build_docker_file_for :fetch).to eq(config.docker.build_docker_file)
  end
end
