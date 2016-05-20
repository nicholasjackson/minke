require 'spec_helper'

describe Minke::Generators::Processor do
  let(:runner) { double("runner") }

  let(:processor) {
    variables = Minke::Generators::ConfigVariables.new.tap do |v|
      v.application_name = 'application_name'
      v.namespace = 'namespace'
      v.src_root = 'srcroot'
    end
    Minke::Generators::Processor.new variables, runner
  }

  describe 'create new filename' do
    it 'removes the extension .erb' do
      f = processor.create_new_filename '.', './file.txt.erb', './out', 'myservice'

      expect(f).to eq('./out/file.txt')
    end

    it 'removes the current template location in the path' do
      f = processor.create_new_filename './template_location', './template_location/file.txt.erb', './out', 'myservice'

      expect(f).to eq('./out/file.txt')
    end

    it 'replaces <%= application_name %> with the name of the application' do
      f = processor.create_new_filename './t', './t/<%= application_name %>/file.txt.erb', './out', 'myservice'

      expect(f).to eq('./out/myservice/file.txt')
    end

    it 'prepends the output folder' do
      f = processor.create_new_filename './t', './t/file.txt.erb', './out', 'myservice'

      expect(f).to eq('./out/file.txt')
    end
  end




end
