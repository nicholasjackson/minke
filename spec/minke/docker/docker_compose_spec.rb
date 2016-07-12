require 'spec_helper'

describe Minke::Docker::DockerCompose do

  let(:project_name) { "tester" }

  let(:system_runner) do
    double("system_runner").tap do |sr|
      allow(sr).to receive(:execute)
      allow(sr).to receive(:write_file)
      allow(sr).to receive(:mktmpdir).and_return('./tmp')
      allow(sr).to receive(:remove_entry_secure)
    end
  end

  let(:composepath) { File.expand_path("../../../data/docker-compose.yml", __FILE__) }

  let(:composefile) do
    <<-EOF
---
version: '2'
networks:
  default:
    external:
      name: tester
      EOF
  end

  describe 'when the docker network environment variable is specified' do
   let(:dockercompose) { Minke::Docker::DockerCompose.new composepath, system_runner, project_name, 'tester' }

    describe 'starting a stack' do

      it 'creates a temporary directory' do
        expect(system_runner).to receive(:mktmpdir)

        dockercompose.up
      end

      it 'writes a temporary file to the temp folder' do
        expect(system_runner).to receive(:write_file).with('./tmp/docker-compose.yml', anything)

        dockercompose.up
      end

      it 'writes the correct settings to the file' do
        expect(system_runner).to receive(:write_file).with('./tmp/docker-compose.yml', composefile)

        dockercompose.up
      end

      it 'calls docker compose with the correct settings' do
        expect(system_runner).to receive(:execute).with("docker-compose -f #{composepath} -f ./tmp/docker-compose.yml -p #{project_name} up -d")

        dockercompose.up
      end

      it 'deletes the temporary folder' do
        expect(system_runner).to receive(:remove_entry_secure).with('./tmp')

        dockercompose.up
      end

    end

    describe 'stopping a stack' do

      it 'creates a temporary directory' do
        expect(system_runner).to receive(:mktmpdir)

        dockercompose.down
      end

      it 'writes a temporary file to the temp folder' do
        expect(system_runner).to receive(:write_file).with('./tmp/docker-compose.yml', anything)

        dockercompose.down
      end

      it 'writes the correct settings to the file' do
        expect(system_runner).to receive(:write_file).with('./tmp/docker-compose.yml', composefile)

        dockercompose.down
      end

      it 'calls docker compose with the correct settings' do
        expect(system_runner).to receive(:execute).with("docker-compose -f #{composepath} -f ./tmp/docker-compose.yml -p #{project_name} down -v")

        dockercompose.down
      end

      it 'deletes the temporary folder' do
        expect(system_runner).to receive(:remove_entry_secure).with('./tmp')

        dockercompose.down
      end

    end

    describe 'streaming the logs' do
      it 'calls docker compose with the correct settings' do
        expect(system_runner).to receive(:execute).with("docker-compose -f #{composepath} -f ./tmp/docker-compose.yml -p #{project_name} logs -f")

        dockercompose.logs
      end

    end

  end

end
