require 'spec_helper'
require_relative './shared_context.rb'

describe Minke::Tasks::TaskRunner, :a => :b do
  let(:runnerargs) do
    {
      :health_check => health_check,
      :rake_helper => rake_helper,
      :copy_helper => copy_helper,
      :service_discovery => service_discovery
    }
  end

  let(:task_runner) { Minke::Tasks::TaskRunner.new runnerargs }

  describe 'run_steps' do

    describe 'rake tasks' do
      it 'executes the defined rake tasks' do 
        expect(rake_helper).to receive(:invoke_task).with('task1')

        task_runner.run_steps config.fetch.pre
      end 

      it 'executes both defined rake tasks' do
        expect(rake_helper).to receive(:invoke_task).twice

        task_runner.run_steps config.fetch.pre
      end
    end

    describe 'copy assets' do
      it 'copies any assets' do
        expect(copy_helper).to receive(:copy_assets).with('/from1', './to1')

        task_runner.run_steps config.fetch.pre
      end

      it 'copies both assets' do
        expect(copy_helper).to receive(:copy_assets).twice

        task_runner.run_steps config.fetch.pre
      end
    end

  end

end