# frozen_string_literal: true

##
# Configuration for Datadog logging
# @!parse
#   class Lumberjack::Datadog::Config; end
module Lumberjack::Datadog
  # Configuration options for Datadog logger
  # @!attribute max_message_length
  #   @return [Integer, nil] Maximum message length
  # @!attribute backtrace_cleaner
  #   @return [Object, nil] Backtrace cleaner
  # @!attribute pid
  #   @return [Boolean, Symbol] PID option
  # @!attribute allow_all_attributes
  #   @return [Boolean] Allow all attributes
  # @!attribute attribute_mapping
  #   @return [Hash] Custom attribute mapping
  # @!attribute pretty
  #   @return [Boolean] Pretty print option
  class Config
    attr_accessor :max_message_length
    attr_accessor :backtrace_cleaner
    attr_accessor :pid
    attr_accessor :allow_all_attributes
    attr_reader :attribute_mapping
    attr_accessor :pretty

    def initialize
      @max_message_length = nil
      @backtrace_cleaner = nil
      @thread_name = false
      @pid = true
      @allow_all_attributes = true
      @attribute_mapping = {}
      @pretty = false
    end

    # Add the thread name to the `logger.thread_name` attribute. This setting is deprecated.
    # Call logger.tag!("logger.thread_name" => -> { Lumberjack::Utils.global_thread_id }) instead.
    #
    # @param value [Boolean, Symbol] Thread name option. Pass :global to use the global thread ID.
    # @return [void]
    # @deprecated
    def thread_name=(value)
      message = "Setting @logger.thread_name through the logger setup is deprecated. Call logger.tag!(\"logger.thread_name\" => -> { Lumberjack::Utils.global_thread_id }) instead."
      Lumberjack::Utils.deprecated(:thread_name=, message) do
        @thread_name = value
      end
    end

    # @deprecated
    attr_reader :thread_name

    # Remap log attributes
    # @param attribute_mapping [Hash] Additional attribute mappings
    # @return [Hash] Updated attribute mapping
    def remap_attributes(attribute_mapping)
      @attribute_mapping = @attribute_mapping.merge(attribute_mapping)
    end

    # Validate configuration options
    # @raise [ArgumentError] if options are invalid
    # @return [void]
    def validate!
      if !max_message_length.nil? && (!max_message_length.is_a?(Integer) || max_message_length <= 0)
        raise ArgumentError, "max_message_length must be a positive integer"
      end

      unless backtrace_cleaner.nil? || backtrace_cleaner.respond_to?(:clean)
        raise ArgumentError, "backtrace_cleaner must respond to #clean"
      end
    end
  end
end
