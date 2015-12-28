require 'arcanus/constants'
require 'arcanus/errors'
require 'arcanus/error_handler'
require 'arcanus/configuration'
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
  def load(directory = Dir.pwd)
    @config = Configuration.load_applicable(directory)
    @repo = Repo.new(@config)

    unless File.directory?(@repo.arcanus_dir)
      raise Errors::UsageError,
            'Arcanus has not been initialized in this repository. ' \
            'Run `arcanus setup`'
    end

    unless File.exist?(@repo.unlocked_key_path)
      raise Errors::UsageError,
            'Arcanus key has not been unlocked. ' \
            'Run `arcanus unlock`'
    end

    @chest = Chest.new(key_file_path: @repo.unlocked_key_path,
                       chest_file_path: @repo.chest_file_path)
  end
end
