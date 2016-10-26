require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::Bundle, :a => :b do
  let(:task) { Minke::Tasks::Bundle.new args}

  it 'calls bundle' do
    generator_config.build_settings.build_commands.fetch = nil

    expect(shell_helper).to receive(:execute).with('bundle install')

    task.run
  end
end
