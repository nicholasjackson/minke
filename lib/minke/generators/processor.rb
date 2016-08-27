module Minke
  module Generators
    ##
    # Process handles the creation of new projects from a generator template.
    class Processor

      def self.load_generators
        Gem::Specification.find_all.each do |spec|
          if spec.metadata != nil && spec.metadata['entrypoint'] != nil
            require spec.metadata['entrypoint']
          end
        end
      end

      def initialize variables, docker_runner, logger
        @logger = logger
        @variables = variables
        @docker_runner = docker_runner
      end

      def process generator_name, output_folder
        generator = get_generator generator_name

        # process the files
        @logger.info '# Modifiying templates'
        @logger.debug "#{generator.template_location}"

        process_directory generator.template_location, '**/*', output_folder, @variables.application_name
        process_directory generator.template_location, '**/.*', output_folder, @variables.application_name

        # run generate command if present
        if generator.generate_settings != nil && generator.generate_settings.command != nil
          image = build_image generator.generate_settings.docker_file  unless generator.generate_settings.docker_file == nil
          image = fetch_image generator.generate_settings.docker_image unless generator.generate_settings.docker_image == nil

          run_command_in_container image, generator.generate_settings.command unless generator.generate_settings.command == nil
        end

        # write the shell script
        Minke::Generators::write_bash_script output_folder + "/_build/minke.sh"
        Minke::Generators::create_rvm_files output_folder + "/_build/", @variables.application_name
      end

      def build_image docker_file
        @logger.info "## Building custom docker image"

        image_name = @variables.application_name + "-buildimage"
        @docker_runner.build_image docker_file, image_name
      end

      def fetch_image docker_image
        @docker_runner.pull_image docker_image unless @docker_runner.find_image docker_image
        docker_image
      end

      def run_command_in_container build_image, command
        @logger.debug command
        begin
          container, success = @docker_runner.create_and_run_container build_image, ["#{File.expand_path(@variables.src_root)}:/src"], nil, '/src', command

          # throw exception if failed
          @helper.fatal_error " #{command}" unless success
          #command = Minke::Helpers.replace_vars_in_section generator.generate_command, '##SERVICE_NAME##', APPLICATION_NAME
          #container, ret = Minke::Docker.create_and_run_container config, command
        ensure
          @docker_runner.delete_container container
        end
      end

      def process_directory template_location, folder, output_folder, service_name
        Dir.glob("#{template_location}/#{folder}").each do |file_name|
          @logger.debug "## Processing #{file_name}"
          process_file template_location, file_name, output_folder, service_name
        end
      end

      def process_file template_location, original, output_folder, service_name
        new_filename = create_new_filename template_location, original, output_folder, service_name

        dirname = File.dirname(new_filename)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end

        if !File.directory?(original)
          if File.extname(original) == ".erb"
            render_erb original, new_filename
          elsif
            FileUtils.cp(original, new_filename)
          end
        end
      end

      def render_erb original, new_filename
        b = binding
        b.local_variable_set(:application_name, @variables.application_name)
        b.local_variable_set(:namespace, @variables.namespace)
        b.local_variable_set(:src_root, @variables.src_root)

        renderer = ERB.new(File.read(original))
        File.open(new_filename, 'w') {|f| f.write renderer.result(b) }
      end

      def create_new_filename template_location, original, output_folder, service_name
        new_filename = original.sub(template_location + '/', '')
        new_filename.sub!('.erb', '')
        new_filename.sub!('<%= application_name %>', service_name)

        output_folder + '/' + new_filename
      end

      ##
      #
      def local_gems
         Gem::Specification.sort_by{ |g| [g.name.downcase, g.version] }.group_by{ |g| g.name }
      end

      def get_generator generator
        config = Minke::Generators.get_registrations.select { |c| c.name == generator}.first
        if config == nil
          throw "Generator not installed please select from the above list of installed generators or install the required gem"
        end
        processor = Minke::Generators::ConfigProcessor.new @variables
        return processor.process config
      end

    end
  end
end
