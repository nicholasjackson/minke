namespace :app do
  desc "run unit tests"
  task :test => ['config:set_docker_env', 'config:load_config', 'docker:fetch_images'] do
  	p "Test application"

    config = GoBuilder::Helpers.config
    container = GoBuilder::GoDocker.get_container config['docker']

  	begin
  		# Get go packages
  		ret = container.exec(['go','get','-t','-v','./...']) { |stream, chunk| puts "#{stream}: #{chunk}" }
  		raise Exception, 'Error running command' unless ret[2] == 0

  		# Test application
  		ret = container.exec(['go','test','./...']) do |stream, chunk|
        puts "#{stream}: #{chunk}"
      end

  		raise Exception, 'Error running command' unless ret[2] == 0
  	ensure
  		container.delete(:force => true)
  	end
  end

  desc "build and test application"
  task :build => [:test] do
  	p "Build for Linux"

    config = GoBuilder::Helpers.config
  	container = GoBuilder::GoDocker.get_container config['docker']

  	begin
  		# Build go server
  		ret = container.exec(
        ['go','build','-a','-installsuffix','cgo','-ldflags','\'-s\'','-o', config['go']['application_name']]
      ) do |stream, chunk|
        puts "#{stream}: #{chunk}"
      end

  		raise Exception, 'Error running command' unless ret[2] == 0
  	ensure
  		container.delete(:force => true)
  	end
  end

  task :copy_assets do
    p "Copy assets"

    config = GoBuilder::Helpers.config

    if config['after_build'] != nil && config['after_build']['copy_assets'] != nil
      GoBuilder::Helpers.copy_files config['after_build']['copy_assets']
    end
  end

  desc "build Docker image for application"
  task :build_server => [:build, :copy_assets] do
    config = GoBuilder::Helpers.config

  	p "Building Docker image: #{config['go']['application_name']}"

  	Docker.options = {:read_timeout => 6200}
  	image = Docker::Image.build_from_dir config['docker']['docker_file'], {:t => config['go']['application_name']}
  end

  desc "run application with Docker Compose"
  task :run => ['config:set_docker_env', 'config:load_config'] do
    p "Run application with docker compose"

    config = GoBuilder::Helpers.config
    compose = GoBuilder::DockerCompose.new config['docker']['compose_file']

  	begin
      compose.up

      if config['run']['consul_loader']['enabled']
        GoBuilder::Helpers.wait_until_server_running "#{config['run']['consul_loader']['url']}/v1/status/leader", 0
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        loader.load_config config['run']['consul_loader']['config_file'], config['run']['consul_loader']['url']
      end

      compose.logs
  	rescue SystemExit, Interrupt
  		compose.stop
  		compose.rm
  	end
  end

  desc "build and run application with Docker Compose"
  task :build_and_run => [:build_server, :run]

  desc "run end to end Cucumber tests USAGE: rake app:cucumber[@tag]"
  task :cucumber, [:feature] => ['config:set_docker_env', 'config:load_config'] do |t, args|
    config = GoBuilder::Helpers.config

  	puts "Running cucumber with tags #{args[:feature]}"

  	if args[:feature] != nil
  		feature = "--tags #{args[:feature]}"
  	else
  		feature = ""
  	end

  	status = 0

    compose = GoBuilder::DockerCompose.new config['docker']['compose_file']
  	begin
  	  compose.up

      if config['cucumber']['consul_loader']['enabled']
        GoBuilder::Helpers.wait_until_server_running "#{config['cucumber']['consul_loader']['url']}/v1/status/leader", 0
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        loader.load_config config['cucumber']['consul_loader']['config_file'], config['cucumber']['consul_loader']['url']
      end

      if config['cucumber']['health_check']['enabled']
        GoBuilder::Helpers.wait_until_server_running config['cucumber']['health_check']['url'], 0
      end

  		sh "cucumber --color -f pretty #{feature}"
      status = $?.exitstatus
  	ensure
  		compose.stop
  		compose.rm

      abort "Cucumber steps failed" unless status == 0
  	end
  end

  desc "push built image to Docker registry"
  task :push => ['config:load_config'] do
  	p "Push image to registry"

    config = GoBuilder::Helpers.config
  	GoBuilder::GoDocker.tag_and_push config
  end
end
