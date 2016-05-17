require 'spec_helper'

describe Minke::Docker::DockerCompose do

  let(:runner) {
    r = double('runner')
    allow(r).to receive(:execute).and_return("0.0.0.0:8000")
    r
  }
  let(:compose) { Minke::Docker::DockerCompose.new File.expand_path('../../../data/docker-compose.yml', __FILE__), runner }

  it 'gets the public ports for any container which has ports exposed in the compose file' do
    expect(runner).to receive(:execute).exactly(4).times

    compose.get_public_ports
  end

  it 'caches results when getting ports' do
    expect(runner).to receive(:execute).exactly(4).times

    compose.get_public_ports
    compose.get_public_ports
  end

  it 'sets the correct server name' do
    ports = compose.get_public_ports
    puts
    expect(ports.first[:name]).to eq('test2')
  end

  it 'sets the correct private port' do
    ports = compose.get_public_ports

    expect(ports.first[:private_port]).to eq('8001')
  end

  it 'sets the correct public port' do
    ports = compose.get_public_ports

    expect(ports.first[:public_port]).to eq('8000')
  end

  it 'sets the correct address' do
    ports = compose.get_public_ports

    expect(ports.first[:address]).to eq('0.0.0.0')
  end

  it 'returns the correct details when getting by name and port' do
    expect(compose.get_port_by_name('test2', '8001')[:name]).to eq('test2')
  end

end
