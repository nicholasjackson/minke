require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Run, :a => :b do
  let(:task) do
    Minke::Tasks::Run.new args  
  end

  it 'calls create on the compose factory' do
    expect(docker_compose_factory).to receive(:create)

    task.run
  end

  it 'starts the compose stack' do
    expect(docker_compose).to receive(:up)

    task.run
  end

  it 'spools the compose logs' do
    expect(docker_compose).to receive(:logs)

    task.run
  end

  it 'stops copose and removes containers' do
    expect(docker_compose).to receive(:down)

    task.run
  end
end
