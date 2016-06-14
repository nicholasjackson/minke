require 'spec_helper'

describe Minke::Docker::ServiceDiscovery do
  let (:containers) do
    j = <<-EOF
    [
      {
        "Names":["/tester_syslog_1"],
        "State": "Running",
        "Ports": [{"PrivatePort": 2222, "PublicPort": 3333, "Type": "tcp"}],
        "NetworkSettings": {
          "Networks": {
            "bridge": {
              "IPAddress": "172.17.0.2"
            }
          }
        }
      }
    ]
    EOF

    JSON.parse j
  end

  let(:project_name) { 'tester' }
  let(:docker_runner) do
    runner = double('docker_runner')
    allow(runner).to receive(:get_docker_ip_address).and_return('127.0.0.1')
    allow(runner).to receive(:running_containers).and_return(containers)

    runner
  end
  let(:discovery) { Minke::Docker::ServiceDiscovery.new project_name, docker_runner }

  it 'returns the public address for the given container' do
    address = discovery.public_address_for 'syslog', 2222

    expect(address).to eq('127.0.0.1:3333')
  end

  it 'returns the private address for the given container' do
    address = discovery.bridge_address_for 'syslog', 2222

    expect(address).to eq('172.17.0.2:2222')
  end

end
