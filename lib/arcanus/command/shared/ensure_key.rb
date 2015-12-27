module Arcanus::Command::Shared
  module EnsureKey
    # Ensures the key is unlocked
    def ensure_key_unlocked
      if !repo.has_locked_key?
        execute_command(%w[setup])
        ui.newline
      elsif !repo.has_unlocked_key?
        execute_command(%w[unlock])
        ui.newline
      end
    end
  end
end
