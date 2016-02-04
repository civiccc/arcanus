require 'pathname'

module Arcanus
  # Exposes information about the current git repository.
  class Repo
    # @param config [Arcanus::Configuration]
    def initialize(config)
      @config = config
    end

    # Returns the absolute path to the root of the current repository the
    # current working directory resides within.
    #
    # @return [String]
    # @raise [Arcanus::Errors::InvalidArcanusRepoError] if the current directory
    #   doesn't reside within a git repository
    def root
      @root ||=
        begin
          arc_dir = Pathname.new(File.expand_path('.'))
                            .enum_for(:ascend)
                            .find do |path|
            # We check for .arcanus first since most repos will have that but
            # not necessarily have .git. However, when running `arcanus setup`,
            # the .arcanus directory won't exist yet, so check for .git
            (path + '.arcanus').exist? || (path + '.git').exist?
          end

          unless arc_dir
            raise Errors::InvalidArcanusRepoError, 'no .arcanus directory found'
          end

          arc_dir.to_s
        end
    end

    def arcanus_dir
      File.join(root, '.arcanus')
    end

    def gitignore_file_path
      File.join(arcanus_dir, '.gitignore')
    end

    def chest_file_path
      File.join(root, CHEST_FILE_PATH)
    end

    def has_chest_file?
      File.exist?(chest_file_path)
    end

    def locked_key_path
      File.join(root, LOCKED_KEY_PATH)
    end

    def has_locked_key?
      File.exist?(locked_key_path)
    end

    def unlocked_key_path
      File.join(root, UNLOCKED_KEY_PATH)
    end

    def has_unlocked_key?
      File.exist?(unlocked_key_path)
    end
  end
end
