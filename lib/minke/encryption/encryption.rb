module Minke
  module Encryption
    class Encryption
      def initialize(private_key_file)
        @key_file = private_key_file
        @key = OpenSSL::PKey::RSA.new File.read private_key_file
      end

      def encrypt_string(string)
        Base64.encode64(@key.public_encrypt(string))
      end

      def decrypt_string(string)
        @key.private_decrypt(Base64.decode64(string))
      end

      def fingerprint
        SSHKey.new(File.read(@key_file)).md5_fingerprint
      end
    end
  end
end
