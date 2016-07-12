require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Tasks::Push, :a => :b do  
  let(:task) do
    Minke::Tasks::Push.new args
  end

  it 'logs into the registry' do
    expect(docker_runner).to receive(:login_registry).with('http://something', 'myuser', 'mypassword', 'nic@dfgdf.com')

    task.run
  end

  it 'logs into the registry' do
    expect(docker_runner).to receive(:tag_image).with('testapp', 'mynamespace/testapp')

    task.run
  end

  it 'tags the image' do
    expect(docker_runner).to receive(:push_image).with('mynamespace/testapp')

    task.run
  end

end
