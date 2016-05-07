module Minke
  module Helpers
    class Copy
      def copy_assets assets
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
end
