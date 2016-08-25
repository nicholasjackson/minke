require 'spec_helper'

describe Minke::Helpers::Logger do

  let(:output) do
    o = double('output')
    allow(o).to receive(:debug)
    allow(o).to receive(:error)
    allow(o).to receive(:info)
    return o
  end

  let(:logger) { return Minke::Helpers::Logger.new(output) }
  let(:verbose_logger) { return Minke::Helpers::Logger.new(output, :verbose) }



  it 'logs with info level' do
    expect(output).to receive(:info).with(/.*something/)

    logger.log "something", :info
  end

  it 'logs with error level' do
    expect(output).to receive(:error).with(/.*something/)

    logger.log "something", :error
  end

  it 'logs with debug level' do
    expect(output).to receive(:debug).with(/.*something/)

    verbose_logger.log "something", :debug
  end

  it 'does not logs with normal level' do
    expect(output).to receive(:debug).never

    logger.log "something", :debug
  end

end