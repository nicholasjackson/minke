module Minke
  module Tasks
    class TaskRunner

      def initialize args
        @health_check = args[:health_check]
        @rake_helper = args[:rake_helper]
        @copy_helper = args[:copy_helper]
        @service_discovery = args[:service_discovery]
      end

      ##
      # execute the defined steps in the given Minke::Config::TaskRunSettings
      def run_steps steps
        execute_rake_tasks steps.tasks unless steps.tasks == nil
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
        @health_check.wait_for_HTTPOK @service_discovery.build_address(url), 0, 3
      end

      ##
      # copys the assets defined in the step
      def copy_assets assets
        assets.each { |a| @copy_helper.copy_assets a.from, a.to }
      end

    end
  end
end