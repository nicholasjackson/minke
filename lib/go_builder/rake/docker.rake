namespace :docker do
  desc "updates build images for swagger and golang will overwrite existing images"
  task :update_images do
  	GoBuilder::GoDocker.pull_image 'golang:latest'
  end

  desc "pull images for golang from Docker registry if not already downloaded"
  task :fetch_images do
  	GoBuilder::GoDocker.pull_image 'golang' unless GoBuilder::GoDocker.find_image 'golang:latest'
  end
end
