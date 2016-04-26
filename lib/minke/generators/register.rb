module Minke
  module Generators
    @@registrations = []

    def register config
      puts "registered #{config.name}"

      @@registrations.push(config)
      #puts "registered #{config.template_location}"
    end

    def get_registrations
      @@registrations
    end

    module_function :register
    module_function :get_registrations
  end
end
