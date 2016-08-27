module Minke
  module Generators
    def write_bash_script path
      FileUtils.cp(File.expand_path('../../scripts/minke', __FILE__), path)
      File.chmod(0755, path)
    end

    def create_rvm_files folder, application_name
      File.write("#{folder}.ruby-gemset", application_name)
      File.write("#{folder}.ruby-version", '2')
    end

    module_function :write_bash_script
    module_function :create_rvm_files
  end
end
