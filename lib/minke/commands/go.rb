module Minke
  module Commands
    class Go
      def config
        {
          :build => {
            :get => ['go','get','-t','-v','-d','./...'],
            :build => ['go','build','-a','-installsuffix','cgo','-ldflags','\'-s\'','-o', "application"],
            :test => ['go','test','./...']
          },
          :docker => {
            :image => 'golang:latest',
            :env => ['CGO_ENABLED=0'],
            :binds => ["#{ENV['GOPATH']}/src:/go/src"]
          }
        }
      end
    end
  end
end
