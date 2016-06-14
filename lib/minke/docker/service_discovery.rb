module Minke
  module Docker
    ##
    # ServiceDiscovery allows you to look up the publicly accessible address and port for a server
    class ServiceDiscovery
      def initialize project_name, docker_runner
        @project_name = project_name
        @docker_runner = docker_runner
      end

      ##
      # Will attempt to locate the public details for a running container given
      # its name and private port
      # Parameters:
      # - service_name: the name of the running service
      # - private_port: the private port which you wish to retrieve an address for
      # Returns:
      # public address for the container e.g. 0.0.0.0:8080
      def public_address_for service_name, private_port
        ip = @docker_runner.get_docker_ip_address
        container_details = find_container_by_name "/#{@project_name}_#{service_name}_1"
        ports = container_details['Ports'].select { |p| p['PrivatePort'] == private_port }.first

        return "#{ip}:#{ports['PublicPort']}"
      end

      ##
      # Will attempt to locate the private details for a running container given
      # its name and private port
      # Parameters:
      # - service_name: the name of the running service
      # - private_port: the private port which you wish to retrieve an address for
      # Returns:
      # private address for the container e.g. 172.17.0.2:8080
      def bridge_address_for service_name, private_port
        container_details = find_container_by_name "/#{@project_name}_#{service_name}_1"
        ip = container_details['NetworkSettings']['Networks']['bridge']['IPAddress']

        return "#{ip}:#{private_port}"
      end

      :private
      def find_container_by_name name
        @docker_runner.running_containers.select { |c| c['Names'].include?(name) }.first
      end
    end
  end
end
