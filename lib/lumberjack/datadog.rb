# frozen_string_literal: true

require "lumberjack_json_device"

# Datadog integration for Lumberjack logging.
#
# This module provides JSON logging functionality specifically designed for Datadog,
# automatically mapping standard log attributes to Datadog's naming conventions
# and providing structured exception and duration logging.
module Lumberjack::Datadog
  # Standard mapping of log attributes to Datadog fields
  # @return [Hash]
  STANDARD_ATTRIBUTE_MAPPING = {
    time: "timestamp",
    severity: "status",
    progname: ["logger", "name"],
    pid: "pid"
  }.freeze

  class << self
    # Returns a mapping of log attributes to JSON fields for Datadog
    # @param pid [Boolean, Symbol] Include process ID
    # @param attribute_mapping [Hash] Custom attribute mapping
    # @param allow_all_attributes [Boolean] Allow all attributes
    # @param max_message_length [Integer, nil] Maximum message length
    # @return [Hash]
    def json_mapping(pid: true, attribute_mapping: {}, allow_all_attributes: true, max_message_length: nil)
      mapping = STANDARD_ATTRIBUTE_MAPPING.dup

      if pid == :global
        mapping[:pid] = ->(pid) { {"pid" => Lumberjack::Utils.global_pid(pid)} }
      else
        mapping.delete(:pid) unless pid
      end

      mapping.merge!(attribute_mapping.transform_keys(&:to_sym))

      mapping[:attributes] = "*" if allow_all_attributes

      mapping[:message] = if max_message_length
        truncate_message_transformer(max_message_length)
      else
        true
      end

      mapping.transform_keys!(&:to_s)
    end

    # Convenience method for setting up a Datadog logger with a block configuration.
    #
    # This method is no longer really needed since Lumberjack 2 makes setting up logger from
    # the constructor easier.
    #
    # @param stream [IO, String, Pathname] Output stream or path
    # @param options [Hash] Logger options
    # @yield [Lumberjack::Datadog::Config] Block for setting up a configuration object for
    #   configuring aspects of the logger.
    # @return [Lumberjack::Logger]
    #
    # @see Config
    def setup(stream = $stdout, options = {}, &block)
      config = Config.new
      yield(config) if block_given?
      config.validate!

      new_logger(stream, options, config)
    end

    private

    # Creates a transformer lambda that truncates messages to a maximum length.
    #
    # @param max_length [Integer] Maximum message length
    # @return [Proc] Message truncation transformer
    def truncate_message_transformer(max_length)
      lambda do |msg|
        msg = msg.inspect unless msg.is_a?(String)
        msg = "#{msg[0, max_length - 1]}…" if msg.length > max_length
        {"message" => msg}
      end
    end

    # Creates a new logger instance with the provided configuration.
    #
    # @param stream [IO, String, Pathname] Output stream or path
    # @param options [Hash] Logger options
    # @param config [Lumberjack::Datadog::Config] Configuration object
    # @return [Lumberjack::Logger] Configured logger instance
    def new_logger(stream, options, config)
      mapping = json_mapping(
        pid: config.pid,
        attribute_mapping: config.attribute_mapping,
        allow_all_attributes: config.allow_all_attributes,
        max_message_length: config.max_message_length
      )

      options = options.merge(output: stream, mapping: mapping, pretty: config.pretty)
      logger = Lumberjack::Logger.new(:datadog, **options)

      # Deprecated behavior
      if config.thread_name
        if config.thread_name == :global
          logger.tag!("logger.thread_name" => -> { Lumberjack::Utils.global_thread_id })
        else
          logger.tag!("logger.thread_name" => -> { Lumberjack::Utils.thread_name })
        end
      end

      logger
    end
  end
end

require_relative "datadog/config"
require_relative "datadog/device"
require_relative "datadog/entry_formatter"
require_relative "datadog/exception_attribute_formatter"
