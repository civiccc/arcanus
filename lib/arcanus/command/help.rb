module Arcanus::Command
  class Help < Base
    description 'Displays help documentation'

    def execute
      ui.print 'Arcanus is a tool for managing encrypted secrets in a repository.'
      ui.newline

      ui.print 'Usage: ', newline: false
      ui.info 'arcanus [command]'
      ui.newline

      command_classes.each do |command_class|
        ui.info command_class.short_name.ljust(12, ' '), newline: false
        ui.print command_class.description
      end

      ui.newline
      ui.print "See #{Arcanus::REPO_URL}#usage for full documentation"
    end

    private

    def command_classes
      command_files =
        Dir[File.join(File.dirname(__FILE__), '*.rb')]
        .select { |path| File.basename(path, '.rb') != 'base' }

      command_files.map do |file|
        require file

        basename = File.basename(file, '.rb')
        Arcanus::Command.const_get(Arcanus::Utils.camel_case(basename))
      end
    end
  end
end
