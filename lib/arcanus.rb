require 'arcanus/constants'
require 'arcanus/errors'
require 'arcanus/error_handler'
require 'arcanus/input'
require 'arcanus/output'
require 'arcanus/ui'
require 'arcanus/repo'
require 'arcanus/subprocess'
require 'arcanus/key'
require 'arcanus/chest'
require 'arcanus/utils'
require 'arcanus/version'

# Exposes API for consumption by external Ruby applications.
module Arcanus
  module_function

  # Returns the Arcanus chest, providing access to encrypted secrets.
  #
  # @return [Arcanus::Chest]
  def chest
    Arcanus.load unless @chest
    @chest
  end

  # Loads Arcanus chest and decrypts secrets.
  #
  # @param directory [String] repo directory
  def load
    @repo = Repo.new

    unless File.directory?(@repo.arcanus_dir)
      raise Errors::UsageError,
            'Arcanus has not been initialized in this repository. ' \
            'Run `arcanus setup`'
    end

    if File.exist?(@repo.unlocked_key_path)
      key = Arcanus::Key.from_file(@repo.unlocked_key_path)
    elsif ENV['ARCANUS_PASSWORD']
      key = Arcanus::Key.from_protected_file(@repo.locked_key_path, ENV['ARCANUS_PASSWORD'])
    else
      raise Errors::UsageError,
            'Arcanus key has not been unlocked. ' \
            'Run `arcanus unlock` or specify password via ARCANUS_PASSWORD environment variable'
    end

    @chest = Chest.new(key: key, chest_file_path: @repo.chest_file_path)
  end
end
