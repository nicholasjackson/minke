module Minke
  class DockerCompose
    @compose_file = nil

    def initialize compose_file
      @compose_file = compose_file
    end

    def up
      execute "docker-compose -f #{@compose_file} up -d"
      sleep 2
    end

    def stop
      execute "docker-compose -f #{@compose_file} stop"
    end

    def rm
      execute "echo y | docker-compose -f #{@compose_file} rm -v"
    end

    def logs
      execute "docker-compose -f #{@compose_file} logs"
    end

    private
    def execute command
      system("#{command}")
    end
  end
end
