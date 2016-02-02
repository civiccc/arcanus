require 'fileutils'

module Arcanus::Command
  class Setup < Base
    description 'Create a chest to store encrypted secrets in the current repository'

    def execute
      return if already_has_key?

      ui.info 'This repository does not have an Arcanus key.'
      ui.info "Let's generate one for you."
      ui.newline

      create_directory
      create_key
      create_chest
      create_gitignore

      ui.newline
      ui.success 'You can safely commit the following files:'
      ui.info Arcanus::CHEST_FILE_PATH
      ui.info Arcanus::LOCKED_KEY_PATH
      ui.success 'You must never commit the unlocked key file:'
      ui.info Arcanus::UNLOCKED_KEY_PATH
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

    def create_directory
      FileUtils.mkdir_p(repo.arcanus_dir)
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
      # Create a dummy file to start so that we can initialize an empty chest,
      # but then use that chest's #save implementation to save the file
      File.open(repo.chest_file_path, 'w') { |f| f.write({}.to_yaml) }

      key = Arcanus::Key.from_file(repo.unlocked_key_path)
      chest = Arcanus::Chest.new(key: key, chest_file_path: repo.chest_file_path)
      chest.save
    end

    def create_gitignore
      File.open(repo.gitignore_file_path, 'a') do |f|
        f.write(File.basename(Arcanus::UNLOCKED_KEY_PATH))
      end
    end
  end
end
