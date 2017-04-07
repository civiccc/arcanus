# frozen_string_literal: true

# Global application constants.
module Arcanus
  EXECUTABLE_NAME = 'arcanus'.freeze

  CHEST_FILE_PATH = File.join('.arcanus', 'chest.yaml').freeze
  LOCKED_KEY_PATH = File.join('.arcanus', 'protected.key').freeze
  UNLOCKED_KEY_PATH = File.join('.arcanus', 'unprotected.key').freeze

  REPO_URL = 'https://github.com/brigade/arcanus'.freeze
  BUG_REPORT_URL = "#{REPO_URL}/issues".freeze
end
