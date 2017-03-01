require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Test, :a => :b do

  let(:task) do
    Minke::Tasks::Shell.new args
  end

  it 'executes the given commands in a container' do
    generator_config.build_settings.build_commands.test = ['command1', 'command2']
    expect(docker_runner).to receive(:create_and_run_container).twice
    
    task.run
  end

end

