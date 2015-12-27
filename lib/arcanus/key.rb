require 'openssl'

module Arcanus
  # Encapsulates operations for creating keys that encrypt/decrypt secrets.
  class Key
    DEFAULT_SIZE = 4096
    PASSWORD_CIPHER = OpenSSL::Cipher.new('AES-256-CBC')

    class << self
      def generate(key_size_bits: DEFAULT_SIZE)
        key = OpenSSL::PKey::RSA.new(key_size_bits)
        new(key)
      end

      def from_file(file_path)
        key = OpenSSL::PKey::RSA.new(File.read(file_path))
        new(key)
      rescue OpenSSL::PKey::RSAError
        raise Errors::DecryptionError,
              "Invalid PEM file #{file_path}"
      end

      def from_protected_file(file_path, password)
        key = OpenSSL::PKey::RSA.new(File.read(file_path), password)
        new(key)
      rescue OpenSSL::PKey::RSAError
        raise Errors::DecryptionError,
              'Either the password is invalid or the PEM file is invalid'
      end
    end

    def initialize(key)
      @key = key
    end

    def save(key_file_path:, password: nil)
      pem =
        if password
          @key.to_pem(PASSWORD_CIPHER, password)
        else
          @key.to_pem
        end

      File.open(key_file_path, 'w') { |f| f.write(pem) }
    end

    def encrypt(plaintext)
      @key.public_encrypt(plaintext)
    end

    def decrypt(ciphertext)
      @key.private_decrypt(ciphertext)
    end
  end
end
