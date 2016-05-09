module Minke
  class DockerComposeFactory
    def create compose_file
      Minke::DockerCompose.new compose_file
    end
  end

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
      execute "echo y | docker-compose -f #{@compose_file} rm -v" unless Docker.info["Driver"] == "btrfs"
    end

    def logs
      execute "docker-compose -f #{@compose_file} logs -f"
    end

    private
    def execute command
      system("#{command}")
    end
  end
end
