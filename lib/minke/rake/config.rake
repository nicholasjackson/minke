namespace :config do
  task :set_docker_env do
    DOCKER_IP = Minke::Docker::DockerRunner.new.get_docker_ip_address
    ENV['DOCKER_IP'] = DOCKER_IP
  end
end
