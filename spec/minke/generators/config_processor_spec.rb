require 'spec_helper'

describe Minke::Generators::ConfigProcessor do

  let (:variable_replacements) do
    Minke::Generators::ConfigVariables.new.tap do |cv|
      cv.src_root = "/src/mypath"
      cv.namespace = "namespace"
      cv.application_name = "myapp"
    end
  end

  let(:generator_config) do
    config = Minke::Generators::Config.new
    config.name = 'test generator'
    config.template_location = './somewhere'

    config.generate_settings = Minke::Generators::GenerateSettings.new.tap do |s|
      s.command = 'mycommand'
      s.docker_image = 'myimage'
      s.docker_file = './soemthing/something'
    end

    config.build_settings = Minke::Generators::BuildSettings.new.tap do |s|
      s.build_commands = Minke::Generators::BuildCommands.new.tap do |b|
        b.fetch = ['stuff']
        b.build = ['build', 'stuff']
        b.test = ['test stuff']
      end

      s.docker_settings = Minke::Generators::DockerSettings.new.tap do |d|
        d.image = 'dockerimage:latest'
        d.env = ['BLAH=BLAH']
        d.binds = ['/src:/src']
        d.working_directory = '/src'
      end
    end

    return config
  end

  let(:generate_settings) { generator_config.generate_settings }
  let(:build_settings) { generator_config.build_settings }
  let(:build_commands) { build_settings.build_commands }
  let(:docker_settings) { build_settings.docker_settings }

  def process config
    processor = Minke::Generators::ConfigProcessor.new variable_replacements
    processor.process config
  end

  describe '<%= src_root %> replacements' do
    it 'replaces <%= src_root %> in template_location' do
      generator_config.template_location = '<%= src_root %>/subfolder'
      process generator_config

      expect(generator_config.template_location).to eq("#{variable_replacements.src_root}/subfolder")
    end

    it 'replaces <%= src_root %> in generate_settings.command' do
      generate_settings.command = 'build -o <%= src_root %>'
      process generator_config

      expect(generator_config.generate_settings.command).to eq("build -o #{variable_replacements.src_root}")
    end

    it 'replaces <%= src_root %> in generate_settings.command' do
      generate_settings.docker_file = '<%= src_root %>/dockerfile'
      process generator_config

      expect(generator_config.generate_settings.docker_file).to eq("#{variable_replacements.src_root}/dockerfile")
    end

    it 'replaces <%= src_root %> in build_settings.build_commands.fetch' do
      build_commands.fetch = ['fetch <%= src_root %>']
      process generator_config

      expect(generator_config.build_settings.build_commands.fetch).to eq(["fetch #{variable_replacements.src_root}"])
    end

    it 'replaces <%= src_root %> in build_settings.build_commands.build' do
      build_commands.build = ['build <%= src_root %>']
      process generator_config

      expect(generator_config.build_settings.build_commands.build).to eq(["build #{variable_replacements.src_root}"])
    end

    it 'replaces <%= src_root %> in build_settings.build_commands.test' do
      build_commands.test = ['test <%= src_root %>', 'test2 <%= src_root %>']
      process generator_config

      expect(generator_config.build_settings.build_commands.test).to eq(
        ["test #{variable_replacements.src_root}", "test2 #{variable_replacements.src_root}"])
    end

    it 'replaces <%= src_root %> in build_settings.docker_settings.image' do
      docker_settings.image = 'image <%= src_root %>'
      process generator_config

      expect(generator_config.build_settings.docker_settings.image).to eq("image #{variable_replacements.src_root}")
    end

    it 'replaces <%= src_root %> in build_settings.docker_settings.env' do
      docker_settings.env = ['test=<%= src_root %>', 'test2=<%= src_root %>']
      process generator_config

      expect(generator_config.build_settings.docker_settings.env).to eq(
        ["test=#{variable_replacements.src_root}", "test2=#{variable_replacements.src_root}"])
    end

    it 'replaces <%= src_root %> in build_settings.docker_settings.binds' do
      docker_settings.binds = ['test:<%= src_root %>', 'test2:<%= src_root %>']
      process generator_config

      expect(generator_config.build_settings.docker_settings.binds).to eq(
        ["test:#{variable_replacements.src_root}", "test2:#{variable_replacements.src_root}"])
    end

    it 'replaces <%= src_root %> in build_settings.docker_settings.working_directory' do
      docker_settings.working_directory = '/test:<%= src_root %>'
      process generator_config

      expect(generator_config.build_settings.docker_settings.working_directory).to eq("/test:#{variable_replacements.src_root}")
    end

  end
end
