module Arcanus::Command
  class Unlock < Base
    description 'Unlocks key so secrets can be encrypted/decrypted'

    def execute
      return if already_unlocked?

      ui.print "This repository's Arcanus key is locked by a password."
      ui.print "Until you unlock it, you won't be able to view/edit secrets."

      unlock_key

      ui.success "Key unlocked and saved in #{repo.unlocked_key_path}"
      ui.newline
      ui.print 'You can now view secrets with:'
      ui.info '  arcanus show'
      ui.print '...or edit secrets with:'
      ui.info '  arcanus edit'
    end

    private

    def already_unlocked?
      return unless repo.has_unlocked_key?

      ui.warning "This repository's key is already unlocked."
      ui.print 'You can view secrets by running:'
      ui.info 'arcanus show'

      true
    end

    def unlock_key
      loop do
        ui.print 'Enter password: ', newline: false
        password = ui.secret_user_input

        begin
          key = Arcanus::Key.from_protected_file(repo.locked_key_path, password)
          key.save(key_file_path: repo.unlocked_key_path)
          break # Key unlocked successfully
        rescue Arcanus::Errors::DecryptionError => ex
          ui.error ex.message
        end
      end
    end
  end
end
