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
    # @raise [Arcanus::Errors::InvalidGitRepoError] if the current directory
    #   doesn't reside within a git repository
    def root
      @root ||=
        begin
          git_dir = Pathname.new(File.expand_path('.'))
                            .enum_for(:ascend)
                            .find do |path|
            (path + '.git').exist?
          end

          unless git_dir
            raise Errors::InvalidGitRepoError, 'no .git directory found'
          end

          git_dir.to_s
        end
    end

    # Returns an absolute path to the .git directory for a repo.
    #
    # @return [String]
    def git_dir
      @git_dir ||=
        begin
          git_dir = File.expand_path('.git', root)

          # .git could also be a file that contains the location of the git directory
          unless File.directory?(git_dir)
            git_dir = File.read(git_dir)[/^gitdir: (.*)$/, 1]

            # Resolve relative paths
            unless git_dir.start_with?('/')
              git_dir = File.expand_path(git_dir, repo_dir)
            end
          end

          git_dir
        end
    end

    def gitignore_file_path
      File.join(root, '.gitignore')
    end

    def chest_file_path
      File.join(root, CHEST_FILE_NAME)
    end

    def has_chest_file?
      File.exist?(chest_file_path)
    end

    def locked_key_path
      File.join(root, LOCKED_KEY_NAME)
    end

    def has_locked_key?
      File.exist?(locked_key_path)
    end

    def unlocked_key_path
      File.join(root, UNLOCKED_KEY_NAME)
    end

    def has_unlocked_key?
      File.exist?(unlocked_key_path)
    end
  end
end
