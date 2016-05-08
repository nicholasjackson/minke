module Minke
  module Tasks
    class Fetch < Task

      def run
        config = Minke::Helpers.config

        puts "## Building Docker image"

        Docker.options = {:read_timeout => 6200}
        image = Docker::Image.build_from_dir config['docker']['docker_file'], {:t => config['application_name']}

        puts ""
      end

    end
  end
end
