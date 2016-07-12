require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Tasks::Build, :a => :b do
  let(:task) do
    Minke::Tasks::Build.new args  
  end

  it 'executes the given commands in a container' do
    generator_config.build_settings.build_commands.build = ['dfdf', 'dfdf']
    expect(docker_runner).to receive(:create_and_run_container).twice

    task.run
  end

  it 'does nothing when there are no commands' do
    generator_config.build_settings.build_commands.build = nil
    expect(docker_runner).to receive(:create_and_run_container).never

    task.run
  end

end
