require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Tasks::TaskRunner, :a => :b do
  let(:runnerargs) do
    {
      :health_check => health_check,
      :ruby_helper => ruby_helper,
      :copy_helper => copy_helper,
      :service_discovery => service_discovery,
      :logger_helper => logger_helper
    }
  end

  let(:task_runner) { Minke::Tasks::TaskRunner.new runnerargs }

  describe 'run_steps' do

    describe 'ruby tasks' do
      it 'executes the defined ruby tasks' do 
        expect(ruby_helper).to receive(:invoke_task).with('task1', logger_helper)

        task_runner.run_steps config.fetch.pre
      end 

      it 'executes both defined rake tasks' do
        expect(ruby_helper).to receive(:invoke_task).twice

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
