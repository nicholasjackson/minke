module Minke
  module Tasks
    class TaskRunner

      def initialize args
        @consul = args[:consul]
        @docker_network = args[:docker_network]
        @health_check = args[:health_check]
        @rake_helper = args[:rake_helper]
        @copy_helper = args[:copy_helper]
        @service_discovery = args[:service_discovery]
      end

      ##
      # execute the defined steps in the given Minke::Config::TaskRunSettings
      def run_steps steps
        execute_rake_tasks steps.tasks unless steps.tasks == nil
        start_consul_and_load_data steps.consul_loader unless steps.consul_loader == nil
        wait_for_health_check steps.health_check unless steps.health_check == nil
        copy_assets steps.copy unless steps.copy == nil
      end

      private

      ##
      # execute an array of rake tasks
      def execute_rake_tasks tasks
        tasks.each { |t| @rake_helper.invoke_task t }
      end

      ##
      # waits until the container health check has succeeded
      def wait_for_health_check url
        @health_check.wait_for_HTTPOK build_address(url), 0, 3
      end

      ##
      # copys the assets defined in the step
      def copy_assets assets
        assets.each { |a| @copy_helper.copy_assets a.from, a.to }
      end

      ##
      # builds an address for the given url
      def build_address url
        if url.type == 'external'
          "#{url.protocol}://#{url.address}:#{url.port}#{url.path}"
        elsif url.type == 'bridge'
          address = @service_discovery.bridge_address_for @docker_network, url.address, url.port
          "#{url.protocol}://#{address}#{url.path}"
        elsif url.type == 'public'
          address = @service_discovery.public_address_for url.address, url.port
          "#{url.protocol}://#{address}#{url.path}"
        end
      end
    end
  end
end