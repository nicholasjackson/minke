module Minke
  class Helpers

    class << self
      attr_accessor :config
    end

    @config = nil

    def self.wait_until_server_running server, count
      begin
        response = RestClient.send("get", server)
      rescue

      end

      if response == nil || !response.code.to_i == 200
        puts "Waiting for server #{server} to start"
        sleep 1
        if count < 20
          self.wait_until_server_running server, count + 1
        else
          raise 'Server failed to start'
        end
      end
    end

    def self.load_config config_file
      @config = YAML.parse(ERB.new(File.read(config_file)).result).transform
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
