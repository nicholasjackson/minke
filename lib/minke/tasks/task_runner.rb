module Minke
  module Tasks
    class TaskRunner

      def initialize args
        @rake_helper       = args[:rake_helper]
        @copy_helper       = args[:copy_helper]
        @service_discovery = args[:service_discovery]
      end

      ##
      # execute the defined steps in the given Minke::Config::TaskRunSettings
      def run_steps steps
        execute_rake_tasks steps.tasks unless steps.tasks == nil
        copy_assets steps.copy unless steps.copy == nil
      end

      private
      ##
      # execute an array of rake tasks
      def execute_rake_tasks tasks
        tasks.each { |t| @rake_helper.invoke_task t }
      end

      ##
      # copys the assets defined in the step
      def copy_assets assets
        assets.each { |a| @copy_helper.copy_assets a.from, a.to }
      end

    end
  end
end