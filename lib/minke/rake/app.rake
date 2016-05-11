namespace :app do

  desc "fetch dependent packages"
  task :fetch => ['config:set_docker_env', 'docker:fetch_images'] do
    create_dependencies
    runner = Minke::Tasks::Fetch.new @config, @config.fetch, @generator_config, @docker_runner, @docker_compose_factory, @logger, @helper
    runner.run
  end

  desc "build application"
  task :build => [:fetch] do
    runner = Minke::Tasks::Run.new
    runner.run
  end

  desc "run unit tests"
  task :test => [:build] do
    runner = Minke::Tasks::Test.new
    runner.run
  end

  desc "build Docker image for application"
  task :build_image => [:test] do
    runner = Minke::Tasks::BuildImage.new
    runner.run
  end

  desc "run application with Docker Compose"
  task :run => ['config:set_docker_env', 'config:load_config'] do
    runner = Minke::Tasks::Run.new
    runner.run
  end

  desc "build and run application with Docker Compose"
  task :build_and_run => [:build_server, :run]

  desc "run end to end Cucumber tests USAGE: rake app:cucumber[@tag]"
  task :cucumber, [:feature] => ['config:set_docker_env'] do |t, args|
    runner = Minke::Tasks::Cucumber.new
    runner.run
  end

  desc "push built image to Docker registry"
  task :push  do
    runner = Minke::Tasks::Push.new
    runner.run
  end

  def create_dependencies
    @config ||= Minke::Config::Reader.new.read './config.yml'

    unless @generator_config != nil
      processor = Minke::Generators::Processor.new @config.application_name, @config.namespace
      processor.load_generators
      @generator_config = processor.get_generator @config.generator_name
    end

    @docker_runner ||= Minke::Docker::DockerRunner.new
    @docker_compose_factory ||= Minke::Docker::DockerComposeFactory.new
    @logger ||= Logger.new(STDOUT)
    @helper ||= Minke::Helpers::Helper.new
  end
end
