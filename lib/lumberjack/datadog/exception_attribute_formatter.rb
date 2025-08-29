# frozen_string_literal: true

##
# Datadog integration for exception attribute formatting
# @!parse
#   module Lumberjack::Datadog; end
module Lumberjack::Datadog
  # Formats exception attributes for Datadog logs
  class ExceptionAttributeFormatter
    # Initialize the exception attribute formatter.
    #
    # @param backtrace_cleaner [Object, nil] Optional backtrace cleaner that responds to #clean
    # @param additional_attributes [Hash] Additional attributes to extract from exception
    def initialize(backtrace_cleaner: nil, additional_attributes: {})
      @backtrace_cleaner = backtrace_cleaner
      @additional_attributes = additional_attributes
    end

    # Format exception attributes for logging.
    #
    # @param error [Exception] The exception to format
    # @return [Hash] Formatted exception attributes with 'kind', 'message', and 'stack' keys
    def call(error)
      error_attributes = {"kind" => error.class.name, "message" => error.message}

      backtrace = error.backtrace
      if backtrace
        backtrace = @backtrace_cleaner.clean(backtrace) if @backtrace_cleaner
        error_attributes["stack"] = backtrace
      end

      @additional_attributes.each do |key, method|
        next unless error.respond_to?(method)

        error_attributes[key.to_s] = error.public_send(method)
      end

      error_attributes
    end
  end
end
