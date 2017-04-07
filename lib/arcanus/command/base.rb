module Arcanus::Command
  # Abstract base class of all commands.
  #
  # @abstract
  class Base
    include Arcanus::Utils

    class << self
      # Create a command from a list of arguments.
      #
      # @param ui [Arcanus::UI]
      # @param arguments [Array<String>]
      # @return [Arcanus::Command::Base] appropriate command for the given
      #   arguments
      def from_arguments(ui, arguments)
        cmd = arguments.first

        begin
          require "arcanus/command/#{Arcanus::Utils.snake_case(cmd)}"
        rescue LoadError
          raise Arcanus::Errors::CommandInvalidError,
                "`arcanus #{cmd}` is not a valid command"
        end

        Arcanus::Command.const_get(Arcanus::Utils.camel_case(cmd)).new(ui, arguments)
      end

      def description(desc = nil)
        @description = desc if desc
        @description
      end

      def short_name
        name.split('::').last.downcase
      end
    end

    # @param ui [Arcanus::UI]
    # @param arguments [Array<String>]
    def initialize(ui, arguments)
      @ui = ui
      @arguments = arguments
    end

    # Parses arguments and executes the command.
    def run
      # TODO: include a parse step here and remove duplicate parsing code from
      # individual commands
      execute
    end

    # Executes the command given the previously-parsed arguments.
    def execute
      raise NotImplementedError, 'Define `execute` in Command subclass'
    end

    # Executes another command from the same context as this command.
    #
    # @param command_arguments [Array<String>]
    def execute_command(command_arguments)
      self.class.from_arguments(ui, command_arguments).execute
    end

    private

    # @return [Array<String>]
    attr_reader :arguments

    # @return [Arcanus::UI]
    attr_reader :ui

    # Returns information about this repository.
    #
    # @return [Arcanus::Repo]
    def repo
      @repo ||= Arcanus::Repo.new
    end
  end
end
