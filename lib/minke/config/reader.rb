module Minke
  module Config
    ##
    # Reader reads a yaml based configuration and processes it into a Minke::Config::Config instance
    class Reader
      def initialize compose_factory
        @compose_factory = compose_factory
      end

      ##
      # read yaml config file and return Minke::Config::Config instance
      def read config_file
        b = binding

        # we need to store a list of all the public server lookups as we process the erb in order to
        # replace them in the config later on
        @public_server_for_replacements = []

        config = Config.new
        file   = ERB.new(File.read(config_file)).result b
        file   = YAML.load(file)

        config.namespace = file['namespace']
        config.application_name = file['application_name']
        config.generator_name = file['generator_name']

        config.docker_registry = read_docker_registry file['docker_registry'] unless file['docker_registry'] == nil
        config.docker          = read_docker_section file['docker']           unless file['docker'] == nil

        config.fetch    = read_task_section file['fetch'], config.docker    unless file['fetch'] == nil
        config.build    = read_task_section file['build'], config.docker    unless file['build'] == nil
        config.run      = read_task_section file['run'], config.docker      unless file['run'] == nil
        config.cucumber = read_task_section file['cucumber'], config.docker unless file['cucumber'] == nil

        return config
      end

      def get_public_server_for server
        @public_server_for_replacements.push("###{server}##")
        "###{server}##"
      end

      def read_docker_registry section
        DockerRegistrySettings.new.tap do |d|
          d.url       = section['url']
          d.user      = section['user']
          d.password  = section['password']
          d.email     = section['email']
          d.namespace = section['namespace']
        end
      end

      def read_docker_section section
        DockerSettings.new.tap do |d|
          d.build_image              = section['build_image']              unless section['build_image'] == nil
          d.build_docker_file        = section['build_docker_file']        unless section['build_docker_file'] == nil
          d.application_docker_file  = section['application_docker_file']  unless section['application_docker_file'] == nil
          d.application_compose_file = section['application_compose_file'] unless section['application_compose_file'] == nil
        end
      end

      def read_task_section section, docker_config
        Task.new.tap do |t|
          t.docker              = read_docker_section section['docker']               unless section['docker'] == nil
          t.pre                 = read_pre_section section['pre']                     unless section['pre'] == nil
          t.post                = read_pre_section section['post']                    unless section['post'] == nil
          t.container_addresses = process_container_addresses t.docker, docker_config

          replace_private_servers t.pre, t.container_addresses unless t.pre == nil
          replace_private_servers t.post, t.container_addresses unless t.post == nil
        end
      end

      def read_pre_section section
        TaskRunSettings.new.tap do |tr|
          tr.tasks         = section['tasks']                                    unless section['tasks'] == nil
          tr.copy          = read_copy_section section['copy']                   unless section['copy'] == nil
          tr.consul_loader = read_consul_loader_section section['consul_loader'] unless section['consul_loader'] == nil
          tr.health_check  = section['health_check']                             unless section['health_check'] == nil
        end
      end

      def read_copy_section section
        section.map do |s|
          Copy.new.tap do |c|
            c.from = s['from']
            c.to   = s['to']
          end
        end
      end

      def read_consul_loader_section section
        ConsulLoader.new.tap do |c|
          c.config_file = section['config_file']
          c.url         = section['url']
        end
      end

      def process_container_addresses section_docker_config, main_docker_config
        compose_file = main_docker_config.application_compose_file    unless main_docker_config.application_compose_file == nil
        compose_file = section_docker_config.application_compose_file unless section_docker_config == nil || section_docker_config.application_compose_file == nil

        compose = @compose_factory.create compose_file
        compose.get_public_ports.map do |pp|
          Minke::Config::ContainerAddress.new.tap do |a|
            a.name = pp[:name]
            a.address = pp[:address]
            a.private_port = pp[:private_port]
            a.public_port = pp[:public_port]
          end
        end
      end

      ##
      # replaces the private servers that have been defined in the config file using the macro
      # <%= get_public_server_for 'test2:8001' %>
      def replace_private_servers section, container_addresses
        @public_server_for_replacements.each do |s|
          parts = s.gsub('##', '').split(':')
          public_server = get_container_addresses_by_name container_addresses, parts.first, parts.last

          section.health_check.gsub!(s, "#{public_server.name}:#{public_server.public_port}")      unless section.health_check == nil
          section.consul_loader.url.gsub!(s, "#{public_server.name}:#{public_server.public_port}") unless section.consul_loader == nil || section.consul_loader.url == nil
        end
      end

      def get_container_addresses_by_name container_addresses, name, private_port
        container_addresses.select { |x| x.name == name && x.private_port == private_port }.first
      end

    end
  end
end
