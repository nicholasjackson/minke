module Minke
  module Commands
    class Go
      def commands config
        {
          :build => {
            :get => [['go','get','-t','-v','-d','./...']],
            :build => [['go','build','-a','-installsuffix','cgo','-ldflags','\'-s\'','-o', "#{config['application_name']}"]],
            :test => [['go','test','./...']]
          },
          :docker => {
            :image => 'golang:latest',
            :env => ['CGO_ENABLED=0'],
            :binds => ["#{ENV['GOPATH']}/src:/go/src"],
            :working_directory => "#{working_directory}"
          }
        }
      end

      def working_directory
        dir = File.expand_path('../.')
        gopath = "#{ENV['GOPATH']}"
        new_dir = "/go" + dir.gsub(gopath,'')
      end
    end
  end
end
