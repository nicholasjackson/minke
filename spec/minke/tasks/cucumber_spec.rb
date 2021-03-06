require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Cucumber, :a => :b do
  let(:task) do
    Minke::Tasks::Cucumber.new args  
  end

  it 'calls create on the compose factory' do
    expect(docker_compose_factory).to receive(:create)

    task.run
  end

  it 'starts the compose stack' do
    expect(docker_compose).to receive(:up)

    task.run
  end

  it 'runs a health check' do
    expect(health_check).to receive(:wait_for_HTTPOK)
    
    task.run
  end

  it 'executes the cucumber shell' do
    expect(shell_helper).to receive(:execute)

    task.run
  end

  it 'stops copose and removes containers' do
    expect(docker_compose).to receive(:down)

    task.run
  end

  it 'throws a fatal error when status from the executed command is false' do
    allow(shell_helper).to receive(:execute).and_raise("nuts")
    expect { task.run }.to raise_error(SystemExit)
  end

  it 'does not throw a fatal error when status from the executed command is 0' do
    allow(shell_helper).to receive(:execute).and_return(true)

    task.run
  end

end
