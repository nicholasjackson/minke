require 'spec_helper'

describe Minke::Logging do
  let(:io) { StringIO.new }
  let(:verbose_logger) {
    Minke::Logging.create_logger(io, true)
  }

  it 'logs error messages with info level' do
    verbose_logger.info "something"

    io.rewind
    expect(io.read).to eq("\e[0;32;49mINFO\e[0m: something\n")
  end
  
  it 'does not log error messages when message is nil' do
    verbose_logger.info nil

    io.rewind
    expect(io.read).to eq("")
  end
end
