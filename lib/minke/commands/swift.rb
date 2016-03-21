module Minke
  module Commands
    class Swift
      def commands config
        {
          :build => {
            :build => ['swift', 'build', '-Xcc', '-fblocks'],
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
