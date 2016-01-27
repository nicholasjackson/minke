namespace :config do
  task :load_config do
    Minke::Helpers.load_config './config.yml'
  end

  task :set_docker_env do
    DOCKER_IP = Minke::GoDocker.get_docker_ip_address
    ENV['DOCKER_IP'] = DOCKER_IP
  end
end
