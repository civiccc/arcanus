require_relative 'shared/ensure_key'
require 'diffy'
require 'tempfile'

module Arcanus::Command
  class Diff < Base
    include Shared::EnsureKey

    description 'Shows what was changed in the chest'

    def execute
      ensure_key_unlocked

      ref = arguments[1] || 'HEAD'

      tempfile = ::Tempfile.new(['old-arcanus-chest', '.yaml']).tap do |file|
        # This will gracefully return an empty string if it doesn't exist
        old_content = `git show #{ref}:#{Arcanus::CHEST_FILE_PATH} 2>/dev/null`.strip

        file.sync = true
        if old_content.empty?
          file.write({}.to_yaml)
        else
          file.write(old_content)
        end
      end

      key = Arcanus::Key.from_file(repo.unlocked_key_path)
      old = Arcanus::Chest.new(key: key, chest_file_path: tempfile).to_yaml
      current = Arcanus::Chest.new(key: key, chest_file_path: repo.chest_file_path).to_yaml

      ui.print(::Diffy::Diff.new(old, current, context: 1).to_s(:color), newline: false)
    end
  end
end
