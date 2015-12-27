module Arcanus::Command
  class Setup < Base
    description 'Create a chest to store encrypted secrets in the current repository'

    def execute
      return if already_has_key?

      ui.info 'This repository does not have an Arcanus key.'
      ui.info "Let's generate one for you."
      ui.newline

      create_key
      create_chest
      update_gitignore

      ui.newline
      ui.success 'You can safely commit the following files:'
      ui.info Arcanus::CHEST_FILE_NAME
      ui.info Arcanus::LOCKED_KEY_NAME
      ui.success 'You must never commit the unlocked key file:'
      ui.info Arcanus::UNLOCKED_KEY_NAME
    end

    private

    def already_has_key?
      return false unless repo.has_locked_key?

      ui.warning 'Arcanus already initialized in this repository.'

      unless repo.has_unlocked_key?
        ui.newline
        ui.warning 'However, your key is still protected by a password.'

        if ui.ask('Do you want to unlock your key? (y/n)')
             .argument(:required)
             .default('y')
             .modify(:downcase)
             .read_string == 'y'
          ui.newline
          execute_command(%w[unlock])
        end
      end

      true
    end

    def create_key
      password = ask_password

      start_time = Time.now
      ui.spinner('Generating key...') do
        key = Arcanus::Key.generate
        key.save(key_file_path: repo.locked_key_path, password: password)
        key.save(key_file_path: repo.unlocked_key_path)
      end
      end_time = Time.now

      ui.success "Key generated in #{end_time - start_time} seconds"
    end

    def ask_password
      password = nil
      confirmed_password = false

      ui.print 'Enter a password to lock the key with.'
      ui.print 'Any new developer will need to be given this password to work with this repo.'
      ui.print 'You should store the password in a secure place.'

      loop do
        ui.info 'Password: ', newline: false
        password = ui.secret_user_input
        ui.newline
        ui.info 'Confirm Password: ', newline: false
        confirmed_password = ui.secret_user_input
        ui.newline

        if password == confirmed_password
          break
        else
          ui.error 'Passwords do not match. Try again.'
          ui.newline
        end
      end

      password
    end

    def create_chest
      File.open(repo.chest_file_path, 'w') { |f| f.write({}.to_yaml) }
    end

    def update_gitignore
      File.open(repo.gitignore_file_path, 'a') { |f| f.write(Arcanus::UNLOCKED_KEY_NAME) }
    end
  end
end
