# frozen_string_literal: true

##
# Datadog device for Lumberjack logging
# @!parse
#   class Lumberjack::Datadog::Device < Lumberjack::JsonDevice; end
module Lumberjack::Datadog
  # Device for sending logs to Datadog with automatic attribute mapping and formatting.
  class Device < Lumberjack::JsonDevice
    Lumberjack::DeviceRegistry.add(:datadog, self)

    # Initialize the Datadog device with Datadog-specific formatting.
    #
    # @param options [Hash] Device options including Datadog-specific configuration
    # @option options [Boolean, Symbol] :pid Include process ID in logs
    # @option options [Hash] :attribute_mapping Custom attribute name mapping
    # @option options [Boolean] :allow_all_attributes Include all log entry attributes
    # @option options [Integer, nil] :max_message_length Maximum message length
    # @option options [Object, nil] :backtrace_cleaner Backtrace cleaner for exceptions
    def initialize(options = {})
      datadog_options = options.dup

      mapping_options = {}
      mapping_options[:pid] = datadog_options.delete(:pid)
      mapping_options[:attribute_mapping] = datadog_options.delete(:attribute_mapping)
      mapping_options[:allow_all_attributes] = datadog_options.delete(:allow_all_attributes)
      mapping_options[:max_message_length] = datadog_options.delete(:max_message_length)
      datadog_options[:mapping] ||= Lumberjack::Datadog.json_mapping(**mapping_options.compact)

      backtrace_cleaner = datadog_options.delete(:backtrace_cleaner)
      @entry_formatter = Lumberjack::Datadog::EntryFormatter.new(backtrace_cleaner: backtrace_cleaner)

      super(datadog_options)
    end

    # Write a log entry with Datadog-specific formatting applied.
    #
    # @param entry [Lumberjack::LogEntry] The log entry to write
    # @return [void]
    def write(entry)
      message, attributes = @entry_formatter.format(entry.message, entry.attributes)
      entry.message = message
      entry.attributes = attributes
      super
    end
  end
end
