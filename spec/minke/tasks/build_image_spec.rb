require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Tasks::BuildImage, :a => :b do
  let(:task) do
    Minke::Tasks::BuildImage.new args
  end

  it 'builds an image from the dockerfile' do
    config.docker.application_docker_file = './docker'
    expect(docker_runner).to receive(:build_image).with('./docker', 'testapp')

    task.run
  end

end
