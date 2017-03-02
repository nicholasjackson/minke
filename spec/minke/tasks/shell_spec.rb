require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Shell, :a => :b do

  let(:task) do
    Minke::Tasks::Shell.new args
  end

  it 'calls create on the compose factory' do
    expect(docker_compose_factory).to receive(:create)

    task.run
  end

  it 'starts the compose stack' do
    expect(docker_compose).to receive(:up)

    task.run
  end

  it 'stops compose and removes containers' do
    expect(docker_compose).to receive(:down)

    task.run
  end

  it 'logs the shell starting message' do
    expect(logger).to receive(:info).with("## Shell open to build container")
    
    task.run
  end

  it 'starts a shell in the build container' do
    expect(docker_runner).to receive(:create_and_run_container).once
    
    task.run
  end

end

