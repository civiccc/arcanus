require 'base64'
require 'digest'
require 'securerandom'
require 'yaml'

module Arcanus
  # Encapsulates the collection of encrypted secrets managed by Arcanus.
  class Chest
    SIGNATURE_SIZE_BITS = 256

    def initialize(key_file_path:, chest_file_path:)
      @key = Key.from_file(key_file_path)
      @chest_file_path = chest_file_path
      @original_encrypted_hash = YAML.load_file(chest_file_path).to_hash
      @original_decrypted_hash = decrypt_hash(@original_encrypted_hash)
      @hash = @original_decrypted_hash.dup
    end

    # Access the collection as if it were a hash.
    #
    # @param key [String]
    # @return [Object]
    def [](key)
      @hash[key]
    end

    # Returns the contents of the chest as a hash.
    def contents
      @hash
    end

    def update(new_hash)
      @hash = new_hash
    end

    # For each key in the chest, encrypt the new value if it has changed.
    #
    # The goal is to create a file where the only lines that differ are the keys
    # that changed.
    def save
      modified_hash =
        process_hash_changes(@original_encrypted_hash, @original_decrypted_hash, @hash)

      File.open(@chest_file_path, 'w') { |f| f.write(modified_hash.to_yaml) }
    end

    private

    def process_hash_changes(original_encrypted, original_decrypted, current)
      result = {}

      current.keys.each do |key|
        value = current[key]

        result[key] =
          if original_encrypted.key?(key)
            # Key still exists; check if modified.
            if original_encrypted[key].is_a?(Hash) && value.is_a?(Hash)
              process_hash_changes(original_encrypted[key], original_decrypted[key], current[key])
            elsif value != original_decrypted[key]
              # Value was changed; encrypt the new value
              encrypt_value(value)
            else
              # Value wasn't changed; keep original encrypted blob
              original_encrypted[key]
            end
          else
            # Key was added
            value.is_a?(Hash) ? process_hash_changes({}, {}, value) : encrypt_value(value)
          end
      end

      result
    end

    def decrypt_hash(hash)
      decrypted_hash = {}

      hash.each do |key, value|
        begin
          if value.is_a?(Hash)
            decrypted_hash[key] = decrypt_hash(value)
          else
            decrypted_hash[key] = decrypt_value(value)
          end
        rescue Errors::DecryptionError => ex
          raise Errors::DecryptionError,
                "Problem decrypting value for key '#{key}': #{ex.message}"
        end
      end

      decrypted_hash
    end

    def encrypt_value(value)
      dumped_value = Marshal.dump(value)
      encrypted_value = Base64.encode64(@key.encrypt(dumped_value))
      salt = SecureRandom.hex(8)

      signature = Digest::SHA2.new(SIGNATURE_SIZE_BITS).tap do |digest|
        digest << salt
        digest << dumped_value
      end.to_s

      "#{encrypted_value}:#{salt}:#{signature}"
    end

    def decrypt_value(blob)
      unless blob.is_a?(String)
        raise Errors::DecryptionError,
              "Expecting an encrypted blob but got '#{blob}'"
      end

      encrypted_value, salt, signature = blob.split(':')

      if signature.nil? || salt.nil? || encrypted_value.nil?
        raise Errors::DecryptionError,
              "Invalid blob format '#{blob}' (must be of the form 'signature:salt:ciphertext')"
      end

      dumped_value = @key.decrypt(Base64.decode64(encrypted_value))

      actual_signature = Digest::SHA2.new(SIGNATURE_SIZE_BITS).tap do |digest|
        digest << salt
        digest << dumped_value
      end.to_s

      if signature != actual_signature
        raise Errors::DecryptionError,
              'Signature of decrypted value does not match: ' \
              "expected #{signature} but got #{actual_signature}"
      end

      Marshal.load(dumped_value)
    end
  end
end
