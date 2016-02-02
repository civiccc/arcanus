require_relative 'shared/ensure_key'
require 'shellwords'

module Arcanus::Command
  class Export < Base
    include Shared::EnsureKey

    description 'Outputs the decrypted values in a format suitable for ' \
                'consumption by other programs'

    def execute
      ensure_key_unlocked

      key = Arcanus::Key.from_file(repo.unlocked_key_path)
      chest = Arcanus::Chest.new(key: key, chest_file_path: repo.chest_file_path)

      env_vars = extract_env_vars(chest.contents)

      output_lines =
        case arguments[1]
        when nil
          env_vars.map { |var, val| "#{var}=#{val.to_s.shellescape}" }
        when '--shell'
          env_vars.map { |var, val| "export #{var}=#{val.to_s.shellescape}" }
        when '--docker'
          # Docker env files don't need any escaping
          env_vars.map { |var, val| "#{var}=#{val}" }
        else
          raise Arcanus::Errors::UsageError, "Unknown export flag #{arguments[1]}"
        end

      ui.print output_lines.join("\n")
    end

    private

    def normalize_key(key)
      key.upcase.tr('-', '_')
    end

    def extract_env_vars(hash, prefix = '')
      output = []

      hash.each do |key, value|
        if value.is_a?(Hash)
          output += extract_env_vars(value, "#{prefix}#{normalize_key(key)}_")
        else
          output << ["#{prefix}#{normalize_key(key)}", value]
        end
      end

      output
    end
  end
end
