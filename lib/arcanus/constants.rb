# Global application constants.
module Arcanus
  EXECUTABLE_NAME = 'arcanus'

  CHEST_FILE_PATH = File.join('.arcanus', 'chest.yaml')
  LOCKED_KEY_PATH = File.join('.arcanus', 'protected.key')
  UNLOCKED_KEY_PATH = File.join('.arcanus', 'unprotected.key')

  REPO_URL = 'https://github.com/sds/arcanus'
  BUG_REPORT_URL = "#{REPO_URL}/issues"
end
