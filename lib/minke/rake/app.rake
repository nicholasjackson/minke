namespace :app do
  desc "run unit tests"
  task :test => ['config:set_docker_env', 'config:load_config', 'docker:fetch_images'] do
  	p "Test application"

    config = Minke::Helpers.config

  	begin
  		# Get go packages
      puts "Go get"
      container, ret = Minke::GoDocker.create_and_run_container config['docker'], ['go','get','-t','-v','-d','./...']
    ensure
  		Minke::GoDocker.delete_container container
  	end

    begin
  		# Test application
      puts "Go test"
      container, ret = Minke::GoDocker.create_and_run_container config['docker'], ['go','test','./...']

  		raise Exception, 'Error running command' unless ret == 0
    ensure
  		Minke::GoDocker.delete_container container
  	end
  end

  desc "build and test application"
  task :build => [:test] do
  	p "Build for Linux"

    config = Minke::Helpers.config

  	begin
  		# Build go server
      container, ret = Minke::GoDocker.create_and_run_container config['docker'], ['go','build','-a','-installsuffix','cgo','-ldflags','\'-s\'','-o', config['go']['application_name']]

  		raise Exception, 'Error running command' unless ret == 0
    ensure
  		Minke::GoDocker.delete_container container
  	end
  end

  task :copy_assets do
    p "Copy assets"

    config = Minke::Helpers.config

    if config['after_build'] != nil && config['after_build']['copy_assets'] != nil
      Minke::Helpers.copy_files config['after_build']['copy_assets']
    end
  end

  desc "build Docker image for application"
  task :build_server => [:build, :copy_assets] do
    config = Minke::Helpers.config

  	p "Building Docker image: #{config['go']['application_name']}"

  	Docker.options = {:read_timeout => 6200}
  	image = Docker::Image.build_from_dir config['docker']['docker_file'], {:t => config['go']['application_name']}
  end

  desc "run application with Docker Compose"
  task :run => ['config:set_docker_env', 'config:load_config'] do
    p "Run application with docker compose"

    config = Minke::Helpers.config
    compose = Minke::DockerCompose.new config['docker']['compose_file']

  	begin
      compose.up

      # do we need to run any tasks after the server starts?
      if config['run']['after_start'] != nil
        config['run']['after_start'].each do |task|
          puts "Running after_start task: #{task}"
          Rake::Task[task].invoke
        end
      end

      if config['run']['consul_loader']['enabled']
        Minke::Helpers.wait_until_server_running "#{config['run']['consul_loader']['url']}/v1/status/leader", 0
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        loader.load_config config['run']['consul_loader']['config_file'], config['run']['consul_loader']['url']
      end

      compose.logs
  	rescue SystemExit, Interrupt
  		compose.stop
  		compose.rm unless Docker.info["Driver"] == "btrfs"
  	end
  end

  desc "build and run application with Docker Compose"
  task :build_and_run => [:build_server, :run]

  desc "run end to end Cucumber tests USAGE: rake app:cucumber[@tag]"
  task :cucumber, [:feature] => ['config:set_docker_env', 'config:load_config'] do |t, args|
    config = Minke::Helpers.config

  	puts "Running cucumber with tags #{args[:feature]}"

  	if args[:feature] != nil
  		feature = "--tags #{args[:feature]}"
  	else
  		feature = ""
  	end

  	status = 0

    compose = Minke::DockerCompose.new config['docker']['compose_file']
  	begin
  	  compose.up

      # do we need to run any tasks after the server starts?
      if config['run']['after_start'] != nil
        config['run']['after_start'].each do |task|
          puts "Running after_start task: #{task}"
          Rake::Task[task].invoke
        end
      end

      if config['cucumber']['consul_loader']['enabled']
        Minke::Helpers.wait_until_server_running "#{config['cucumber']['consul_loader']['url']}/v1/status/leader", 0
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        loader.load_config config['cucumber']['consul_loader']['config_file'], config['cucumber']['consul_loader']['url']
      end

      if config['cucumber']['health_check']['enabled']
        Minke::Helpers.wait_until_server_running config['cucumber']['health_check']['url'], 0
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

    config = Minke::Helpers.config
  	Minke::GoDocker.tag_and_push config
  end
end
