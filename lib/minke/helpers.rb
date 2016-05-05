module Minke
  class Helpers

    class << self
      attr_accessor :config
    end

    @config = nil

    def self.wait_until_server_running server, count, successes = 0
      begin
        response = RestClient.send("get", server)
      rescue

      end

      if response == nil || !response.code.to_i == 200
        puts "Waiting for server #{server} to start: #{count}"
        sleep 1
        if count < 200
          self.wait_until_server_running server, count + 1
        else
          raise 'Server failed to start'
        end
      else
        if successes > 0
          puts "Server: #{server} passed health check, #{successes} checks to go..."
          sleep 1
          self.wait_until_server_running server, count + 1, successes - 1
        else
          puts "Server: #{server} healthy"
        end
      end
    end

    def self.load_config config_file
      @config = YAML.parse(ERB.new(File.read(config_file)).result).transform
      build_commands = Minke::Generators.get_registrations.first.build_commands

      @config[:build_config] = build_commands

      self.replace_vars_in_config @config
    end

    def self.replace_vars_in_config config
       config[:build_config][:docker][:binds] = self.replace_var config[:build_config][:docker][:binds], '##SRC_ROOT##', File.expand_path('../')
       config[:build_config][:docker][:working_directory] = self.replace_var config[:build_config][:docker][:working_directory], '##SRC_ROOT##', File.expand_path('../')

       config[:build_config][:docker][:binds] = self.replace_var config[:build_config][:docker][:binds], '##APPLICATION_NAME##', config['application_name']
       config[:build_config][:docker][:working_directory] = self.replace_var config[:build_config][:docker][:working_directory], '##APPLICATION_NAME##', config['application_name']
    end

    def self.replace_var var, original, new
      self.replace_vars_in_section(var, original, new)
    end

    def self.replace_vars_in_section original, variable, value
      if original.kind_of?(Array)
        original.map { |var| var.gsub(variable, value) }
      else
        original.gsub(variable, value)
      end
    end

    def self.copy_files assets
      assets.each do |a|
        directory = a['to']
        if File.directory?(a['to'])
          directory = File.dirname(a['to'])
        end

        Dir.mkdir directory unless Dir.exist? a['to']
        FileUtils.cp a['from'], a['to']
      end
    end

  end
end
