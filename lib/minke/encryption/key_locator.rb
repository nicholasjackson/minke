module Minke
  module Encryption
    class KeyLocator
      def initialize(key_store_path)
        @key_store_path = key_store_path
      end

      def locate_key fingerprint
        Dir.entries(@key_store_path).each do |f|
          begin
            full_path = "#{@key_store_path}/#{f}"
            key = SSHKey.new(File.read(full_path))

            return full_path if key.fingerprint == fingerprint
          rescue

          end
        end

        throw "Unable to find SSL key matching fingerprint if your SSL keys are not in ~/.ssh you can set the environment variable SSL_KEY_PATH to point to the correct directory."
      end
    end
  end
end
