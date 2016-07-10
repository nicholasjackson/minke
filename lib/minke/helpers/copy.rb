module Minke
  module Helpers
    class Copy
      ##
      # copy assets from one location to another
      def copy_assets from, to
        directory = to
        if File.directory?(to)
          directory = File.dirname(to)
        end

        Dir.mkdir directory unless Dir.exist? to
        FileUtils.cp_r from, to
      end
    end
  end
end