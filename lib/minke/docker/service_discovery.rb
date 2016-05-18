module Minke
  module Docker
    class ContainerAddress
      ##
      # name of the container when started by docker
      attr_accessor :name

      ##
      # the private port the started container is running on
      attr_accessor :private_port

      ##
      # the public port the started container is running on
      attr_accessor :public_port

      ##
      # the publicly available address for the container
      attr_accessor :address
    end

    class ServiceDiscovery

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
