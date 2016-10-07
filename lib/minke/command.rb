module Minke
  class Command
    attr_accessor :config, :generator_config, :verbose

    def initialize(config, generator_config, verbose)
      self.config = config
      self.generator_config = generator_config
      self.verbose = verbose
    end

    # Creates dependencies for minke
    def create_dependencies task
      project_name = "minke#{SecureRandom.urlsafe_base64(12)}".downcase.gsub(/[^0-9a-z ]/i, '')
      network_name = ENV['DOCKER_NETWORK'] ||= "#{project_name}_default"
      ENV['DOCKER_PROJECT'] = project_name
      ENV['DOCKER_NETWORK'] = network_name

      logger = Minke::Logging.create_logger(self.verbose)
      shell = Minke::Helpers::Shell.new(logger)

      variables = Minke::Generators::ConfigVariables.new.tap do |v|
        v.application_name = @config.application_name
        v.namespace = @config.namespace
        v.src_root = File.expand_path('../')
      end

      task_runner = Minke::Tasks::TaskRunner.new ({
        :rake_helper       => Minke::Helpers::Rake.new,
        :copy_helper       => Minke::Helpers::Copy.new,
        :service_discovery => Minke::Docker::ServiceDiscovery.new(project_name, Minke::Docker::DockerRunner.new(logger), network_name),
        :logger_helper     => logger
      })

      consul = Minke::Docker::Consul.new(
        {
          :health_check => Minke::Docker::HealthCheck.new(logger),
          :service_discovery => Minke::Docker::ServiceDiscovery.new( project_name, Minke::Docker::DockerRunner.new(logger, network_name), network_name),
          :consul_loader => ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new),
          :docker_runner => Minke::Docker::DockerRunner.new(logger, network_name),
          :network => network_name,
          :project_name => project_name,
          :logger_helper => logger
        }
      )

      network = Minke::Docker::Network.new(
        network_name,
        shell
      )

      return {
        :config                 => @config,
        :task_name              => task,
        :docker_runner          => Minke::Docker::DockerRunner.new(logger, network_name),
        :task_runner            => task_runner,
        :shell_helper           => shell,
        :logger_helper          => logger,
        :generator_config       => generator_config,
        :docker_compose_factory => Minke::Docker::DockerComposeFactory.new(shell, project_name, network_name),
        :consul                 => consul,
        :docker_network         => network,
        :health_check           => Minke::Docker::HealthCheck.new(logger),
        :service_discovery      => Minke::Docker::ServiceDiscovery.new(project_name, Minke::Docker::DockerRunner.new(logger), network_name)
      } 
    end

    def create_tasks task
      dependencies = create_dependencies(task)
      return {
        :bundler     => Minke::Tasks::Bundle.new(dependencies),
        :fetch       => Minke::Tasks::Fetch.new(dependencies),
        :build       => Minke::Tasks::Build.new(dependencies),
        :test        => Minke::Tasks::Test.new(dependencies),
        :run         => Minke::Tasks::Run.new(dependencies),
        :build_image => Minke::Tasks::BuildImage.new(dependencies),
        :cucumber    => Minke::Tasks::Cucumber.new(dependencies),
        :push        => Minke::Tasks::Push.new(dependencies)
      }
    end

    def fetch
      if config.fetch != nil
        tasks = create_tasks :fetch
        tasks[:bundler].run
        tasks[:fetch].run
      end
    end

    def build
      if config.build != nil
        fetch
        tasks = create_tasks :build
        tasks[:build].run
      end
    end

    def test
      if config.test != nil
        build
        tasks = create_tasks :test
        tasks[:test].run
      end
    end

    def run
      if config.run != nil
        tasks = create_tasks :run
        tasks[:run].run
      end
    end
    
    def build_image
      if config.test != nil
        test
        tasks = create_tasks :build
        tasks[:build_image].run
      end
    end

    def cucumber
      if config.cucumber != nil
        tasks = create_tasks :cucumber
        tasks[:cucumber].run
      end
    end

    def push
      tasks = create_tasks :push
      tasks[:push].run
    end

  end
end
