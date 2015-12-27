module Arcanus::Command
  class Version < Base
    description 'Displays version information'

    def execute
      ui.info Arcanus::VERSION
    end
  end
end
