require 'minke'

reader = Minke::Config::Reader.new
@config = reader.read './config.yml'

namespace :app do
  desc "fetch dependent packages"
  task :fetch => ['config:set_docker_env'] do
    if @config.fetch != nil
      puts 'run fetch'
      runner = Minke::Tasks::Fetch.new create_dependencies :fetch
      runner.run
    end
  end

  desc "build application"
  task :build => [:fetch] do
    if @config.build != nil
      runner = Minke::Tasks::Build.new create_dependencies :build
      runner.run
    end
  end

  desc "run unit tests"
  task :test => [:build] do
    if @config.test != nil
      runner = Minke::Tasks::Test.new create_dependencies :test
      runner.run
    end
  end

  desc "build Docker image for application"
  task :build_image => [:test] do
    if @config.build != nil
      runner = Minke::Tasks::BuildImage.new create_dependencies :build
      runner.run
    end
  end

  desc "run application with Docker Compose"
  task :run => ['config:set_docker_env'] do
    if @config.run != nil
      runner = Minke::Tasks::Run.new create_dependencies :run
      runner.run
    end
  end

  desc "build and run application with Docker Compose"
  task :build_and_run => [:build_image, :run]

  desc "run end to end Cucumber tests USAGE: rake app:cucumber[@tag]"
  task :cucumber, [:feature] => ['config:set_docker_env'] do |t, args|
    if @config.cucumber != nil
      runner = Minke::Tasks::Cucumber.new create_dependencies :cucumber
      runner.run
    end
  end

  desc "push built image to Docker registry"
  task :push  do
    runner = Minke::Tasks::Push.new create_dependencies :push
    runner.run
  end

  def create_dependencies task
    project_name = "minke#{SecureRandom.urlsafe_base64(12)}".downcase.gsub(/[^0-9a-z ]/i, '')
    network_name = ENV['DOCKER_NETWORK'] ||= "#{project_name}_default"
    ENV['DOCKER_PROJECT'] = project_name
    ENV['DOCKER_NETWORK'] = network_name

    variables = Minke::Generators::ConfigVariables.new.tap do |v|
      v.application_name = @config.application_name
      v.namespace = @config.namespace
      v.src_root = File.expand_path('../')
    end

    Minke::Generators::Processor.load_generators
    processor = Minke::Generators::Processor.new variables, @docker_runner

    generator_config = processor.get_generator @config.generator_name

    task_runner = Minke::Tasks::TaskRunner.new ({
      :rake_helper       => Minke::Helpers::Rake.new,
      :copy_helper       => Minke::Helpers::Copy.new,
      :service_discovery => Minke::Docker::ServiceDiscovery.new(project_name, Minke::Docker::DockerRunner.new, network_name) 
    })

    consul = Minke::Docker::Consul.new( 
      Minke::Docker::HealthCheck.new,
      Minke::Docker::ServiceDiscovery.new( project_name, Minke::Docker::DockerRunner.new(network_name), network_name),
      ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new),
      Minke::Docker::DockerRunner.new(network_name),
      network_name,
      project_name
    )

    network = Minke::Docker::Network.new(
      network_name,
      Minke::Helpers::Shell.new
    )

    return {
      :config                 => @config,
      :task_name              => task,
      :docker_runner          => Minke::Docker::DockerRunner.new(network_name),
      :task_runner            => task_runner,
      :error_helper           => Minke::Helpers::Error.new,
      :shell_helper           => Minke::Helpers::Shell.new,
      :logger_helper          => Minke::Helpers::Logger.new,
      :generator_config       => generator_config,
      :docker_compose_factory => Minke::Docker::DockerComposeFactory.new(Minke::Helpers::Shell.new, project_name, network_name),
      :consul                 => consul,
      :docker_network         => network,
      :health_check           => Minke::Docker::HealthCheck.new,
      :service_discovery      => Minke::Docker::ServiceDiscovery.new(project_name, Minke::Docker::DockerRunner.new, network_name)
    }
  end
end
