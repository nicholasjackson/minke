module Minke
  module Config
    ##
    # Reader reads a yaml based configuration and processes it into a Minke::Config::Config instance
    class Reader
      ##
      # read yaml config file and return Minke::Config::Config instance
      def read config_file
        b = binding

        config = Config.new
        file   = ERB.new(File.read(config_file)).result b
        file   = YAML.load(file)

        config.namespace        = file['namespace']
        config.application_name = file['application_name']
        config.generator_name   = file['generator_name']

        config.docker_registry = read_docker_registry file['docker_registry'] unless file['docker_registry'] == nil
        config.docker          = read_docker_section file['docker']           unless file['docker'] == nil

        config.fetch    = read_task_section file['fetch'], config.docker    unless file['fetch'] == nil
        config.build    = read_task_section file['build'], config.docker    unless file['build'] == nil
        config.test     = read_task_section file['test'], config.docker     unless file['test'] == nil
        config.run      = read_task_section file['run'], config.docker      unless file['run'] == nil
        config.cucumber = read_task_section file['cucumber'], config.docker unless file['cucumber'] == nil

        return config
      end

      def read_docker_registry section
        DockerRegistrySettings.new.tap do |d|
          d.url       = section['url'].is_a?(Hash) ? read_secure(section['url']) : section['url']
          d.user      = section['user'].is_a?(Hash) ? read_secure(section['user']) : section['user']
          d.password  = section['password'].is_a?(Hash) ? read_secure(section['password']) : section['password']
          d.email     = section['email'].is_a?(Hash) ? read_secure(section['email']) : section['email']
          d.namespace = section['namespace'].is_a?(Hash) ? read_secure(section['namespace']) : section['namespace']
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
          t.docker = read_docker_section section['docker'] unless section['docker'] == nil
          t.pre    = read_pre_post_section section['pre']  unless section['pre'] == nil
          t.post   = read_pre_post_section section['post'] unless section['post'] == nil
        end
      end

      def read_pre_post_section section
        TaskRunSettings.new.tap do |tr|
          tr.tasks         = section['tasks']                                    unless section['tasks'] == nil
          tr.copy          = read_copy_section section['copy']                   unless section['copy'] == nil
          tr.consul_loader = read_consul_loader_section section['consul_loader'] unless section['consul_loader'] == nil
          tr.health_check  = read_url section['health_check']                    unless section['health_check'] == nil
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
          c.url         = read_url section['url']
        end
      end

      def read_url section
        URL.new.tap do |url|
          url.address  = section['address']
          url.port     = section['port']     != nil ? section['port'].to_s : '80'
          url.path     = section['path']     != nil ? section['path'] : ''
          url.protocol = section['protocol'] != nil ? section['protocol'] : 'http'
          url.type     = section['type']
        end
      end

      def read_secure hash
        key_path = ENV['SSL_KEY_PATH'].to_s == '' ? '~/.ssh' : ENV['SSL_KEY_PATH']


        fingerprint = hash['secure']['fingerprint']
        value = hash['secure']['value']

        locator = Minke::Encryption::KeyLocator.new key_path
        key_path = locator.locate_key fingerprint

        encrypt = Minke::Encryption::Encryption.new key_path
        encrypt.decrypt_string value
      end

    end
  end
end
