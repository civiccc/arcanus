require_relative 'shared/ensure_key'

module Arcanus::Command
  class Show < Base
    include Shared::EnsureKey

    description 'Shows the decrypted contents of the chest'

    def execute
      ensure_key_unlocked

      key = Arcanus::Key.from_file(repo.unlocked_key_path)
      chest = Arcanus::Chest.new(key: key, chest_file_path: repo.chest_file_path)

      if arguments.size > 1
        # Print specific key
        value = chest.get(arguments[1])
        if value.is_a?(Hash)
          output_colored_hash(value)
        else
          ui.print value
        end
      else
        # Print entire hash
        output_colored_hash(chest.to_hash)
      end
    end

    private

    def output_colored_hash(hash, indent = 0)
      indentation = ' ' * indent
      hash.each do |key, value|
        ui.info "#{indentation}#{key}:", newline: false

        if value.is_a?(Hash)
          ui.newline
          output_colored_hash(value, indent + 2)
        else
          ui.print " #{value}"
        end
      end
    end
  end
end
