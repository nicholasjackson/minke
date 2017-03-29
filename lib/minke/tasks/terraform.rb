module Minke
  module Tasks
    class Terraform < Task

      def run args
        @logger.info "## Provision application " + args

        if @task_settings.terraform.environment != nil
          @logger.info "### Setting environment variables "
          @task_settings.terraform.environment.each do |e|
            ENV[e[0]] = e[1]
          end
        end

        Dir.chdir @task_settings.terraform.config_dir do
          @shell_helper.execute "echo yes | terraform #{args}", true
        end
      end

    end
  end
end

