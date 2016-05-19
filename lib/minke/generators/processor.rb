module Minke
  module Generators
    ##
    # Process handles the creation of new projects from a generator template.
    class Processor

      def initialize variables
        @variables = variables
      end

      def process generator_name, output_folder
        generator = get_generator generator_name

        # process the files
        puts '# Modifiying templates'
        puts "#{generator.template_location}"

        process_directory generator.template_location, '**/*', output_folder, @variables.application_name
        process_directory generator.template_location, '**/.*', output_folder, @variables.application_name

        # run generate command if present
        if generator.generate_settings != nil && generator.generate_settings.command
          build_image unless generator.generate_settings.command.docker_file == nil
          fetch_image unless generator.generate_settings.command.docker_image == nil

          #run_command_in_container
        end
      end

      def build_image
        puts "## Building custom docker image"

        image_name = APPLICATION_NAME + "-buildimage"
        Docker.options = {:read_timeout => 6200}
        image = Docker::Image.build_from_dir generator.generate_command_docker_file, {:t => image}
      end

      def fetch_image
        Minke::Docker.pull_image generator.generate_command_docker_image unless Minke::Docker.find_image generator.generate_command_docker_image
        image_name = generator.generate_command_docker_image
      end

      def run_command_in_container
        begin
          config = {
            :build_config => {
              :docker => {
                :image => image_name,
                :binds => ["#{File.expand_path(options[:output])}:/src"],
                :working_directory => "/src"
              }
            }
          }

          #command = Minke::Helpers.replace_vars_in_section generator.generate_command, '##SERVICE_NAME##', APPLICATION_NAME
          #container, ret = Minke::Docker.create_and_run_container config, command
        ensure
        #  Minke::Docker.delete_container container
        end
      end

      def process_directory template_location, folder, output_folder, service_name
        Dir.glob("#{template_location}/#{folder}").each do |file_name|
          puts "## Processing #{file_name}"
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

      def load_generators
        puts '# Loading installed generators'
        Gem::Specification.find_all.each do |spec|
          if spec.metadata != nil && spec.metadata['entrypoint'] != nil
            require spec.metadata['entrypoint']
          end
        end
      end

      def get_generator generator
        config = Minke::Generators.get_registrations.select { |c| c.name == generator}.first
        if config == nil
          puts "Generator not installed please select from the above list of installed generators or install the required gem"
          exit 1
        end
        processor = Minke::Generators::ConfigProcessor.new @variables
        return processor.process config
      end

    end
  end
end
