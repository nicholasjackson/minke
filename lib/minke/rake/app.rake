namespace :app do

  desc "get dependent packages"
  task :get => ['config:set_docker_env', 'config:load_config', 'docker:fetch_images'] do
    config = Minke::Helpers.config

    if config[:build_config][:build][:get] != nil
      puts "## Get dependent packages"
      config[:build_config][:build][:get].each do |command|
      	begin
          container, ret = Minke::Docker.create_and_run_container config, command
        ensure
      		Minke::Docker.delete_container container
      	end
      end
      puts ""
    end
  end

  desc "build application"
  task :build => [:get] do
  	puts "## Build for Linux"
    config = Minke::Helpers.config

    if config['build'] != nil && config['build']['before'] != nil
      config['build']['before'].each do |task|
        puts "## Running before build task: #{task}"
        Rake::Task[task].invoke

        puts ""
      end
    end

    config[:build_config][:build][:build].each do |command|
    	begin
    		# Build application
        container, ret = Minke::Docker.create_and_run_container config, command
        raise Exception, 'Error running command' unless ret == 0
      ensure
    		Minke::Docker.delete_container container
    	end
    end

    puts ""
  end

  desc "run unit tests"
  task :test => [:build] do
    config = Minke::Helpers.config

    if config['test'] != nil && config['test']['before'] != nil
      config['test']['before'].each do |task|
        puts "## Running before test task: #{task}"
        Rake::Task[task].invoke

        puts ""
      end
    end

    puts "## Test application"
    config[:build_config][:build][:test].each do |command|
      begin
  		  # Test application
        container, ret = Minke::Docker.create_and_run_container config, command
      	raise Exception, 'Error running command' unless ret == 0
      ensure
    		Minke::Docker.delete_container container
    	end
    end

    puts ""
  end

  task :copy_assets do
    puts "## Copy assets"

    config = Minke::Helpers.config

    if config['after_build'] != nil && config['after_build']['copy_assets'] != nil
      Minke::Helpers.copy_files config['after_build']['copy_assets']
    end

    puts ""
  end

  desc "build Docker image for application"
  task :build_server => [:build, :copy_assets] do
    config = Minke::Helpers.config

  	puts "## Building Docker image"

  	Docker.options = {:read_timeout => 6200}
  	image = Docker::Image.build_from_dir config['docker']['docker_file'], {:t => config['application_name']}

    puts ""
  end

  desc "run application with Docker Compose"
  task :run => ['config:set_docker_env', 'config:load_config'] do
    puts "## Run application with docker compose"

    config = Minke::Helpers.config

    if config['run']['docker'] != nil && config['run']['docker']['compose_file'] != nil
      config_file = config['run']['docker']['compose_file']
    else
      config_file = config['docker']['compose_file']
    end

    compose = Minke::DockerCompose.new config_file

  	begin
      compose.up

      # do we need to run any tasks after the server starts?
      if config['run']['after_start'] != nil
        config['run']['after_start'].each do |task|
          puts "## Running after_start task: #{task}"
          Rake::Task[task].invoke

          puts ""
        end
      end

      if config['run']['consul_loader']['enabled']
        Minke::Helpers.wait_until_server_running "#{config['run']['consul_loader']['url']}/v1/status/leader", 0
        loader = ConsulLoader::Loader.new(ConsulLoader::ConfigParser.new)
        loader.load_config config['run']['consul_loader']['config_file'], config['run']['consul_loader']['url']

        puts ""
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

  	puts "## Running cucumber with tags #{args[:feature]}"

  	if args[:feature] != nil
  		feature = "--tags #{args[:feature]}"
  	else
  		feature = ""
  	end

  	status = 0

    config = Minke::Helpers.config

    if config['cucumber']['docker'] != nil && config['cucumber']['docker']['compose_file'] != nil
      config_file = config['cucumber']['docker']['compose_file']
    else
      config_file = config['docker']['compose_file']
    end

    compose = Minke::DockerCompose.new config_file

  	begin
  	  compose.up

      # do we need to run any tasks after the server starts?
      if config['cucumber']['after_start'] != nil
        config['cucumber']['after_start'].each do |task|
          puts "## Running after_start task: #{task}"
          Rake::Task[task].invoke

          puts ""
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
  		compose.rm unless Docker.info["Driver"] == "btrfs"

      abort "Cucumber steps failed" unless status == 0
  	end
  end

  desc "push built image to Docker registry"
  task :push => ['config:load_config'] do
  	puts "## Push image to registry"

    config = Minke::Helpers.config
  	Minke::GoDocker.tag_and_push config
  end
end
