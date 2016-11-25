require 'arcanus'

module Arcanus
  # Command line application interface.
  class CLI
    # Set of semantic exit codes we can return.
    #
    # @see http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
    module ExitCodes
      OK          = 0   # Successful execution
      ERROR       = 1   # Generic error
      USAGE       = 64  # User error (bad command line or invalid input)
      SOFTWARE    = 70  # Internal software error (bug)
      CONFIG      = 78  # Configuration error (invalid file or options)
    end

    # Create a CLI that outputs to the given output destination.
    #
    # @param input [Arcanus::Input]
    # @param output [Arcanus::Output]
    def initialize(input:, output:)
      @ui = UI.new(input, output)
    end

    # Parses the given command-line arguments and executes appropriate logic
    # based on those arguments.
    #
    # @param [Array<String>] arguments
    # @return [Integer] exit status code
    def run(arguments)
      run_command(arguments)

      ExitCodes::OK
    rescue => ex
      ErrorHandler.new(@ui).handle(ex)
    end

    private

    # Executes the appropriate command given the list of command line arguments.
    #
    # @param ui [Arcanus::UI]
    # @param arguments [Array<String>]
    # @raise [Arcanus::Errors::ArcanusError] when any exceptional circumstance occurs
    def run_command(arguments)
      arguments = convert_arguments(arguments)

      require 'arcanus/command/base'
      Command::Base.from_arguments(@ui, arguments).run
    end

    def convert_arguments(arguments)
      # Display all open changes by default
      return ['help'] if arguments.empty? # TODO: Evaluate repo and recommend next step

      return ['help'] if %w[-h --help].include?(arguments.first)
      return ['version'] if %w[-v --version].include?(arguments.first)

      arguments
    end
  end
end
