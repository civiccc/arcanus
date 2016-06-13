module Arcanus::Command
  class Unlock < Base
    description 'Unlocks key so secrets can be encrypted/decrypted'

    def execute
      return unless has_chest?
      return if already_unlocked?

      unlock_key

      ui.success "Key unlocked and saved in #{repo.unlocked_key_path}"
      ui.newline
      ui.print 'You can now view secrets with:'
      ui.info '  arcanus show'
      ui.print '...or edit secrets with:'
      ui.info '  arcanus edit'
    end

    private

    def has_chest?
      return true if repo.has_chest_file?

      ui.error 'This repository does not have an Arcanus chest.'
      ui.print 'Create one by running:'
      ui.info 'arcanus setup'

      false
    end

    def already_unlocked?
      return unless repo.has_unlocked_key?

      ui.warning "This repository's key is already unlocked."
      ui.print 'You can view secrets by running:'
      ui.info 'arcanus show'

      true
    end

    def unlock_key
      if ENV.key?('ARCANUS_PASSWORD')
        unlock_key_via_env
      else
        unlock_key_interactive
      end
    end

    def unlock_key_interactive
      ui.print "This repository's Arcanus key is locked by a password."
      ui.print "Until you unlock it, you won't be able to view/edit secrets."

      loop do
        ui.print 'Enter password: ', newline: false
        password = ui.secret_user_input
        ui.newline

        begin
          key = Arcanus::Key.from_protected_file(repo.locked_key_path, password)
          key.save(key_file_path: repo.unlocked_key_path)
          break # Key unlocked successfully
        rescue Arcanus::Errors::DecryptionError => ex
          ui.error ex.message
        end
      end
    end

    def unlock_key_via_env
      ui.print 'ARCANUS_PASSWORD environment variable detected. Attempting to unlock chest...'
      begin
        key = Arcanus::Key.from_protected_file(repo.locked_key_path, ENV['ARCANUS_PASSWORD'])
        key.save(key_file_path: repo.unlocked_key_path)
        ui.success 'Chest unlocked!'
      rescue Arcanus::Errors::DecryptionError => ex
        ui.error 'Unable to unlock key using the ARCANUS_PASSWORD environment variable provided!'
        ui.error ex.message
      end
    end
  end
end
