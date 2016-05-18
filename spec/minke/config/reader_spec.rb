require 'spec_helper'

describe Minke::Config::Reader do
  let(:compose) do
    c = Minke::Docker::DockerCompose.new nil, nil

    allow(c).to receive(:get_public_ports).and_return([
      {:name => 'consul', :private_port => '8500', :public_port => '9500', :address => '0.0.0.0'},
      {:name => 'test2', :private_port => '8001', :public_port => '9001', :address => '0.0.0.0'}
    ])

    allow(c).to receive(:get_port_by_name).and_call_original
    return c
  end

  let(:compose_factory) do
    dc = double('compose_factory')
    allow(dc).to receive(:create).and_return(compose)
    return dc
  end

  let(:config) do
    ENV['DOCKER_REGISTRY_URL'] = 'http://myURL'
    ENV['DOCKER_REGISTRY_USER'] = 'myuser'
    ENV['DOCKER_REGISTRY_PASS'] = 'mypass'
    ENV['DOCKER_REGISTRY_EMAIL'] = 'myemail'
    ENV['DOCKER_NAMESPACE'] = 'namespace/namespace'
    ENV['GOPATH'] = '/go/src'
    ENV['DOCKER_IP'] = 'docker.local'

    reader = Minke::Config::Reader.new compose_factory
    reader.read File.expand_path "../../../data/config_go.yml", __FILE__
  end

  it 'should correctly read the namespace' do
    expect(config.namespace).to eq('github.com/nicholasjackson')
  end

  it 'should correctly read the application_name' do
    expect(config.application_name).to eq('event-sauce')
  end

  it 'should correctly read the generator_name' do
    expect(config.generator_name).to eq('golang')
  end

  describe 'docker_registry section' do
    it 'should correctly read the url' do
      expect(config.docker_registry.url).to eq(ENV['DOCKER_REGISTRY_URL'])
    end

    it 'should correctly read the user' do
      expect(config.docker_registry.user).to eq(ENV['DOCKER_REGISTRY_USER'])
    end

    it 'should correctly read the password' do
      expect(config.docker_registry.password).to eq(ENV['DOCKER_REGISTRY_PASS'])
    end

    it 'should correctly read the email' do
      expect(config.docker_registry.email).to eq(ENV['DOCKER_REGISTRY_EMAIL'])
    end

    it 'should correctly read the namespace' do
      expect(config.docker_registry.namespace).to eq(ENV['DOCKER_NAMESPACE'])
    end
  end

  describe 'docker section' do
    it 'should correctly read the build_image' do
      expect(config.docker.build_image).to eq('golang:latest')
    end

    it 'should correctly read the build_docker_file' do
      expect(config.docker.build_docker_file).to eq('./something/something')
    end

    it 'should correctly read the application_docker_file' do
      expect(config.docker.application_docker_file).to eq('./dockerfiles/event-sauce/Dockerfile')
    end

    it 'should correctly read the application_compose_file' do
      expect(config.docker.application_compose_file).to eq('./dockercompose/event-sauce/docker-compose.yml')
    end
  end

  describe 'build section' do
    describe 'pre' do
      describe 'tasks' do
        it 'should correctly read 2 tasks' do
          expect(config.build.pre.tasks).to contain_exactly('task1', 'task2')
        end
      end

      describe 'copy' do
        it 'should correctly read 2 copy elements' do
          expect(config.build.pre.copy.length).to be(2)
        end

        it 'should have a from value' do
          expect(config.build.pre.copy[0].from).to eq("/go/src/src/github.com/nicholasjackson/event-sauce/event-sauce")
        end

        it 'should have a to value' do
          expect(config.build.pre.copy[0].to).to eq("./docker/event-sauce")
        end
      end

      describe 'consul_loader' do
        it 'should read the config_file correctly' do
          expect(config.build.pre.consul_loader.config_file).to eq('./config.yml')
        end

        it 'should read the url correctly substituting private for public ports' do
          expect(config.build.pre.consul_loader.url).to eq('http://consul:9500')
        end
      end

      describe 'health_check' do
        it 'should correctly read the health_check url substituting private for public ports' do
          expect(config.build.pre.health_check).to eq('http://test2:9001/v1/health')
        end
      end
    end
    describe 'docker' do
      it 'should correctly read the build_image' do
        expect(config.build.docker).to be_an_instance_of(Minke::Config::DockerSettings)
      end
    end

    describe 'post' do
      it 'should correctly read the post section' do
        expect(config.build.post).to be_an_instance_of(Minke::Config::TaskRunSettings)
      end
    end

    describe 'container_addresses' do
      it 'should correctly process the container addresses and obtain their public ports using the global compose file' do
        expect(compose_factory).to have_received(:create).with(config.docker.application_compose_file).twice
        expect(config.build.container_addresses.length).to be(2)
      end

      #{:name => 'consul', :private_port => '8500', :public_port => '9500', :address => '0.0.0.0'},
      it 'should set the correct name' do
        expect(config.build.container_addresses.first.name).to eq('consul')
      end

      it 'should set the correct private_port' do
        expect(config.build.container_addresses.first.private_port).to eq('8500')
      end

      it 'should set the correct public_port' do
        expect(config.build.container_addresses.first.public_port).to eq('9500')
      end

      it 'should set the correct address' do
        expect(config.build.container_addresses.first.address).to eq('0.0.0.0')
      end
    end
  end

  describe 'fetch section' do
    it 'should correctly read the fetch section' do
      expect(config.fetch).to be_an_instance_of(Minke::Config::Task)
    end
  end

  describe 'run section' do
    it 'should correctly read the run section' do
      expect(config.run).to be_an_instance_of(Minke::Config::Task)
    end

    it 'should correctly process the container addresses and obtain their public ports using the task compose file' do
      expect(compose_factory).to have_received(:create).with(config.run.docker.application_compose_file).twice
      expect(config.build.container_addresses.length).to be(2)
    end
  end

  describe 'cucumber section' do
    it 'should correctly read the run section' do
      expect(config.cucumber).to be_an_instance_of(Minke::Config::Task)
    end
  end

end
