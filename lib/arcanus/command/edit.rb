require_relative 'shared/ensure_key'
require 'tempfile'

module Arcanus::Command
  class Edit < Base
    include Shared::EnsureKey

    description 'Opens $EDITOR to modify the contents of the chest'

    def execute
      ensure_key_unlocked

      unless editor_defined?
        raise Arcanus::Errors::ConfigurationError,
              '$EDITOR environment variable is not defined'
      end

      chest = Arcanus::Chest.new(key_file_path: repo.unlocked_key_path,
                                 chest_file_path: repo.chest_file_path)

      ::Tempfile.new('arcanus-chest').tap do |file|
        file.sync = true
        file.write(chest.contents.to_yaml)
        edit_until_done(chest, file.path)
      end
    end

    private

    def editor_defined?
      !ENV['EDITOR'].strip.empty?
    end

    def edit_until_done(chest, tempfile_path)
      # Keep editing until there are no syntax errors or user decides to quit
      loop do
        unless system(ENV['EDITOR'], tempfile_path)
          ui.error 'Editor exited unsuccessfully; ignoring any changes made.'
          break
        end

        begin
          update_chest(chest, tempfile_path)
          ui.success 'Chest updated successfully'
          break
        rescue => ex
          ui.error "Error occurred while modifying the chest: #{ex.message}"

          unless ui.ask('Do you want to try editing the same file again? (y/n)')
                   .argument(:required)
                   .default('y')
                   .modify('downcase')
                   .read_string == 'y'
            break
          end
        end
      end
    end

    def update_chest(chest, tempfile_path)
      changed_hash = YAML.load_file(tempfile_path).to_hash
      chest.update(changed_hash)
      chest.save # TODO: Show diff and let user accept/reject before saving
    end
  end
end
