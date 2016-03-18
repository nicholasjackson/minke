# docker run -i -t -v $(pwd)/../:/src -w /src ibmcom/kitura-ubuntu:latest /bin/bash -c "swift build -Xcc -fblocks"
module Minke
  module Commands
    class Swift
      def commands
        {
          :build => {
            :build => ['swift', 'build', '-Xcc', '-fblocks'],
            :get => ['ls', '-ls'],
            :test => ['ls', '-ls'],
          },
          :docker => {
            :image => 'ibmcom/kitura-ubuntu:latest',
            :binds => ["#{source_directory}:/src"],
            :working_directory => "/src"
          }
        }
      end

      def source_directory
        Dir.pwd if File.exists?('Package.swift')
        File.expand_path('../.') if File.exists?('../Package.swift')
      end
    end
  end
end
