require 'spec_helper'

describe Minke::Docker::Network do
  let(:shell) do 
    sh = double('shell')
    allow(sh).to receive(:execute)
    allow(sh).to receive(:execute_and_return)
    return sh 
  end

  let(:network) { Minke::Docker::Network.new('tester', shell) }

  it 'creates a new network when an existing network does not exist' do
    expect(shell).to receive(:execute).with('docker network create tester')
    network.create
  end

  it 'does not create a new network when a network exist' do
    allow(shell).to receive(:execute_and_return).and_return('tester')
    expect(shell).to receive(:execute).with('docker network create tester').never

    network.create
  end

  it 'removes a network when an existing network does not exist and has been created' do
    expect(shell).to receive(:execute).with('docker network create tester')
    expect(shell).to receive(:execute).with('docker network rm tester', true)

    network.create

    allow(shell).to receive(:execute_and_return).and_return('tester')

    network.remove
  end

  it 'does not remove a network when a network does notexist' do
    expect(shell).to receive(:execute).with('docker network rm tester', true).never
    network.remove
  end

  it 'does not remove a network when a network exists but was not created by this class' do
    allow(shell).to receive(:execute_and_return).and_return('tester')
    expect(shell).to receive(:execute).with('docker network rm tester', true).never
    network.remove
  end

end
