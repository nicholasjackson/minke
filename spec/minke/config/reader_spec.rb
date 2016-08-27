require 'spec_helper'
require_relative '../shared_context.rb'

describe Minke::Config::Reader, :a => :b do  

  let(:config) do
    ENV['DOCKER_REGISTRY_URL'] = 'http://myURL'
    ENV['DOCKER_REGISTRY_USER'] = 'myuser'
    ENV['DOCKER_REGISTRY_PASS'] = 'mypass'
    ENV['DOCKER_REGISTRY_EMAIL'] = 'myemail'
    ENV['DOCKER_NAMESPACE'] = 'namespace/namespace'
    ENV['GOPATH'] = '/go/src'
    ENV['DOCKER_IP'] = 'docker.local'
    ENV['SSL_KEY_PATH'] = File.expand_path("../../../data", __FILE__)

    reader = Minke::Config::Reader.new logger_helper
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
    it 'should correctly read the url when the url is secure' do
      expect(config.docker_registry.url).to eq('http://myURL')
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

      describe 'health_check' do
        it 'should correctly read the health_check url address' do
          expect(config.build.health_check.address).to eq('test2')
        end

        it 'should correctly read the health_check url port' do
          expect(config.build.health_check.port).to eq('8001')
        end

        it 'should correctly default port to 80 when not present' do
          expect(config.fetch.health_check.port).to eq('80')
        end

        it 'should correctly read the health_check url path' do
          expect(config.build.health_check.path).to eq('/v1/health')
        end

        it 'should correctly default path to  when not present' do
          expect(config.fetch.health_check.path).to eq('')
        end

        it 'should correctly read the health_check url protocol' do
          expect(config.build.health_check.protocol).to eq('https')
        end

        it 'should correctly default protocol to http when not present' do
          expect(config.fetch.health_check.protocol).to eq('http')
        end

        it 'should correctly read the health_check url type' do
          expect(config.build.health_check.type).to eq('private')
        end
      end

      describe 'consul_loader' do
        it 'should read the config_file correctly' do
          expect(config.build.consul_loader.config_file).to eq('./config.yml')
        end

        it 'should read the url correctly substituting private for public ports' do
          expect(config.build.consul_loader.url).to be_an_instance_of(Minke::Config::URL)
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
  end

  describe 'fetch section' do
    it 'should correctly read the fetch section' do
      expect(config.fetch).to be_an_instance_of(Minke::Config::Task)
    end
  end

  describe 'test section' do
    it 'should correctly read the fetch section' do
      expect(config.test).to be_an_instance_of(Minke::Config::Task)
    end
  end

  describe 'run section' do
    it 'should correctly read the run section' do
      expect(config.run).to be_an_instance_of(Minke::Config::Task)
    end
  end

  describe 'cucumber section' do
    it 'should correctly read the run section' do
      expect(config.cucumber).to be_an_instance_of(Minke::Config::Task)
    end
  end

end
