module Arcanus
  # A miscellaneous set of utility functions.
  module Utils
    module_function

    # Converts a string containing underscores/hyphens/spaces into CamelCase.
    #
    # @param [String] string
    # @return [String]
    def camel_case(string)
      string.split(/_|-| /)
            .map { |part| part.sub(/^\w/, &:upcase) }
            .join
    end

    # Convert string containing camel case or spaces into snake case.
    #
    # @see stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
    #
    # @param [String] string
    # @return [String]
    def snake_case(string)
      string.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    end

    # Returns a deep copy of the specified hash.
    #
    # @param hash [Hash]
    # @return [Hash]
    def deep_dup(hash)
      hash.each_with_object({}) do |(key, value), dup|
        dup[key] = value.is_a?(Hash) ? deep_dup(value) : value
      end
    end
  end
end
