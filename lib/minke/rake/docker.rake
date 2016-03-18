namespace :docker do
  desc "updates build images for swagger and golang will overwrite existing images"
  task :update_images do
    config = Minke::Helpers.config

    puts "## Updating Docker images"
  	Minke::Docker.pull_image config[:build_config][:docker][:image]

    puts ""
  end

  desc "pull images for golang from Docker registry if not already downloaded"
  task :fetch_images do
    config = Minke::Helpers.config
    
    puts "## Pulling Docker images"
  	Minke::Docker.pull_image config[:build_config][:docker][:image] unless Minke::Docker.find_image config[:build_config][:docker][:image]

    puts ""
  end
end
