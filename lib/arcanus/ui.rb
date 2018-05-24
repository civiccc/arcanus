require 'forwardable'
require 'pastel'
require 'tty-prompt'
require 'tty-spinner'
require 'tty-table'

module Arcanus
  # Manages all interaction with the user.
  class UI
    extend Forwardable

    def_delegators :@prompt, :ask, :confirm

    # Creates a {UI} that mediates between the given input/output streams.
    #
    # @param input [Arcanus::Input]
    # @param output [Arcanus::Output]
    def initialize(input, output)
      @input = input
      @output = output
      @pastel = Pastel.new(enabled: output.tty?)
      @prompt = TTY::Prompt.new
    end

    # Get user input, stripping extraneous whitespace.
    #
    # @return [String, nil]
    def user_input
      if input = @input.get
        input.strip
      end
    rescue Interrupt
      exit 130 # User cancelled
    end

    # Get user input without echoing (useful for passwords).
    #
    # Does not strip extraneous whitespace (since it could be part of password).
    #
    # @return [String, nil]
    def secret_user_input
      if input = @input.get(noecho: true)
        input.chomp # Remove trailing newline as it is not part of password
      end
    rescue Interrupt
      exit 130 # User cancelled
    end

    # Print the specified output.
    #
    # @param output [String]
    # @param newline [Boolean] whether to append a newline
    def print(output, newline: true)
      @output.print(output)
      @output.print("\n") if newline
    end

    # Print output in bold face.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def bold(*args, **kwargs)
      print(@pastel.bold(*args), **kwargs)
    end

    # Print the specified output in a color indicative of error.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def error(args, **kwargs)
      print(@pastel.red(*args), **kwargs)
    end

    # Print the specified output in a bold face and color indicative of error.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def bold_error(*args, **kwargs)
      print(@pastel.bold.red(*args), **kwargs)
    end

    # Print the specified output in a color indicative of success.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def success(*args, **kwargs)
      print(@pastel.green(*args), **kwargs)
    end

    # Print the specified output in a color indicative of a warning.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def warning(*args, **kwargs)
      print(@pastel.yellow(*args), **kwargs)
    end

    # Print the specified output in a color indicating information.
    #
    # @param args [Array]
    # @param kwargs [Hash]
    def info(*args, **kwargs)
      print(@pastel.cyan(*args), **kwargs)
    end

    # Print a blank line.
    def newline
      print('')
    end

    # Execute a command with a spinner animation until it completes.
    def spinner(*args)
      spinner = TTY::Spinner.new(*args)
      spinner_thread = Thread.new do
        loop do
          sleep 0.1
          spinner.spin
        end
      end

      yield
    ensure
      spinner_thread.kill
      newline # Ensure next line of ouptut on separate line from spinner
    end

    # Prints a table.
    #
    # Customize the table by passing a block and operating on the table object
    # passed to that block to add rows and customize its appearance.
    def table(options = {})
      t = TTY::Table.new(options)
      yield t
      print(t.render(:unicode, options))
    end
  end
end
