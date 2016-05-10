namespace :docker do
  desc "updates build images for swagger and golang will overwrite existing images"
  task :update_images do
    config = Minke::Config::Reader.new.read './config.yml'

    puts "## Updating Docker images"
    runner = Minke::Docker::DockerRunner.new
  	runner.pull_image config.docker.build_image

    puts ""
  end

  desc "pull images for golang from Docker registry if not already downloaded"
  task :fetch_images do
    config = Minke::Config::Reader.new.read './config.yml'

    puts "## Pulling Docker images"
    runner = Minke::Docker::DockerRunner.new
  	runner.pull_image config.docker.build_image unless runner.find_image config.docker.build_image

    puts ""
  end
end
