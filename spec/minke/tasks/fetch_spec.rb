require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Tasks::Fetch, :a => :b do
  let(:task) do
    Minke::Tasks::Fetch.new args  
  end

  it 'reads the gemset and sets the name' do
    generator_config.build_settings.build_commands.fetch = nil
    expect(shell_helper).to receive(:read_file).with('.ruby-gemset')

    task.run
  end

  it 'checks if rvm is installed as a user' do
    generator_config.build_settings.build_commands.fetch = nil
    ENV['HOME'] = '/user/njackson'
    expect(shell_helper).to receive(:exist?).with('/user/njackson/.rvm/scripts/rvm')

    task.run
  end

  it 'checks if rvm is installed as root' do
    generator_config.build_settings.build_commands.fetch = nil
    expect(shell_helper).to receive(:exist?).with('/usr/local/rvm/scripts/rvm')

    task.run
  end

  it 'calls bundle with the correct args when rvm is installed as a user' do
    ENV['HOME'] = '/user/njackson'
    generator_config.build_settings.build_commands.fetch = nil
    allow(shell_helper).to receive(:read_file).and_return('minke')
    allow(shell_helper).to receive(:exist?).with('/user/njackson/.rvm/scripts/rvm').and_return(true)
    

    expect(shell_helper).to receive(:execute).with('/bin/bash -c \'source /user/njackson/.rvm/scripts/rvm && rvm gemset use minke && bundle install -j3 && bundle update\'')

    task.run
  end

  it 'calls bundle with the correct args when rvm is installed as a root' do
    ENV['HOME'] = '/user/njackson'
    generator_config.build_settings.build_commands.fetch = nil
    allow(shell_helper).to receive(:read_file).and_return('minkeroot')
    allow(shell_helper).to receive(:exist?).with('/usr/local/rvm/scripts/rvm').and_return(true)
    

    expect(shell_helper).to receive(:execute).with('/bin/bash -c \'source /usr/local/rvm/scripts/rvm && rvm gemset use minkeroot && bundle install -j3 && bundle update\'')

    task.run
  end

  it 'executes the given commands in a container' do
    generator_config.build_settings.build_commands.fetch = ['dfdf', 'dfdf']
    expect(args[:docker_runner]).to receive(:create_and_run_container).twice

    task.run
  end

end
