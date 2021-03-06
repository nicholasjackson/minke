require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Fetch, :a => :b do
  let(:task) do
    Minke::Tasks::Fetch.new args
  end

  it 'executes the given commands in a container' do
    generator_config.build_settings.build_commands.fetch = ['dfdf', 'dfdf']
    expect(args[:docker_runner]).to receive(:create_and_run_container).twice

    task.run
  end

end
