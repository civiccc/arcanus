# Collection of errors that can be thrown by the application.
#
# This implements an exception hierarchy which exceptions to be grouped by type
# so the {ExceptionHandler} can display them appropriately.
module Arcanus::Errors
  # Base class for all errors reported by this tool.
  class ArcanusError < StandardError; end

  # Base class for all errors that are a result of incorrect user usage.
  class UsageError < ArcanusError; end

  # Base class for all configuration-related errors.
  class ConfigurationError < ArcanusError; end

  # Raised when something is incorrect with the configuration.
  class ConfigurationInvalidError < ConfigurationError; end

  # Raised when a configuration file is not present.
  class ConfigurationMissingError < ConfigurationError; end

  # Raised when there was a problem decrypting a value.
  class DecryptionError < StandardError; end

  # Raised when a command has failed due to user error.
  class CommandFailedError < UsageError; end

  # Raised when invalid/non-existent command was used.
  class CommandInvalidError < UsageError; end

  # Raised when run in a directory not part of a repository with Arcanus
  # installed.
  class InvalidArcanusRepoError < UsageError; end

  # Raised when a key path corresponding to a non-existent key is specified.
  class InvalidKeyPathError < UsageError; end
end
