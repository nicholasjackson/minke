require 'pry'

module Minke
  module Docker
    ##
    # ServiceDiscovery allows you to look up the publicly accessible address and port for a server
    class ServiceDiscovery
      def initialize project_name, docker_runner, docker_network = nil
        @project_name = project_name
        @docker_runner = docker_runner
        @docker_network = docker_network
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
        begin
          ip = @docker_runner.get_docker_ip_address
          container_details = find_container_by_name "/#{@project_name}_#{service_name}_1"
          #puts container_details
          ports = container_details.first.info['Ports'].select { |p| p['PrivatePort'] == private_port.to_i }.first
        rescue Exception => e
          raise "Unable to find public address for '#{service_name}' on port #{private_port}"
        end

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
        begin
          container_details = find_container_by_name "/#{@project_name}_#{service_name}_1"
          ip = container_details.first.info['NetworkSettings']['Networks']["#{@docker_network}"]['IPAddress']
        rescue
          raise "Unable to find bridge address for network: #{@docker_network}, container: #{service_name}, port: #{private_port}"
        end
        return "#{ip}:#{private_port}"
      end

      ##
      # builds an address for the given url
      def build_address url
        if url.type == 'external'
          "#{url.protocol}://#{url.address}:#{url.port}#{url.path}"
        elsif url.type == 'bridge'
          address = bridge_address_for url.address, url.port
          "#{url.protocol}://#{address}#{url.path}"
        elsif url.type == 'public'
          address = public_address_for url.address, url.port
          "#{url.protocol}://#{address}#{url.path}"
        end
      end

      private
      def find_container_by_name name
        containers = @docker_runner.running_containers
        containers.select { |c| c.info['Names'].include?(name) }
      end
    end
  end
end
