# frozen_string_literal: true

require "lumberjack_json_device"

##
# Datadog integration for Lumberjack logging
# @!parse
#   module Lumberjack::Datadog; end
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
    def setup(stream = $stdout, options = {}, &block)
      config = Config.new
      yield(config) if block_given?
      config.validate!

      new_logger(stream, options, config)
    end

  # Returns a mapping of log attributes to JSON fields for Datadog
  # @param pid [Boolean, Symbol] Include process ID
  # @param thread_name [Boolean, Symbol] Include thread name
  # @param attribute_mapping [Hash] Custom attribute mapping
  # @param allow_all_attributes [Boolean] Allow all attributes
  # @param max_message_length [Integer, nil] Maximum message length
  # @return [Hash]
  def json_mapping(pid: true, thread_name: false, attribute_mapping: {}, allow_all_attributes: true, max_message_length: nil)
      mapping = attribute_mapping.transform_keys(&:to_sym)
      mapping = mapping.merge(STANDARD_ATTRIBUTE_MAPPING)

      mapping.delete(:pid) if !pid || pid == :global

      mapping[:attributes] = "*" if allow_all_attributes

      mapping[:message] = if max_message_length
        truncate_message_transformer(max_message_length)
      else
        "message"
      end

      mapping.transform_keys!(&:to_s)
    end

    private

    def new_logger(stream, options, config)
      entry_formatter = EntryFormatter.new(backtrace_cleaner: config.backtrace_cleaner)

      mapping = json_mapping(
        pid: config.pid,
        thread_name: config.thread_name,
        attribute_mapping: config.attribute_mapping,
        allow_all_attributes: config.allow_all_attributes,
        max_message_length: config.max_message_length
      )

      options = options.merge(
        output: stream,
        formatter: entry_formatter,
        mapping: mapping,
        pretty: config.pretty
      )
      logger = Lumberjack::Logger.new(:datadog, **options)

      if config.thread_name
        if config.thread_name == :global
          logger.tag!("logger.thread_name" => -> { Lumberjack::Utils.global_thread_id })
        else
          logger.tag!("logger.thread_name" => -> { Lumberjack::Utils.thread_name })
        end
      end

      if config.pid == :global
        logger.tag!("pid" => -> { Lumberjack::Utils.global_pid })
      end

      logger
    end

    def truncate_message_transformer(max_length)
      lambda do |msg|
        msg = msg.inspect unless msg.is_a?(String)
        msg = msg[0, max_length] if msg.is_a?(String) && msg.length > max_length
        {"message" => msg}
      end
    end
  end
end

require_relative "datadog/config"
require_relative "datadog/device"
require_relative "datadog/entry_formatter"
require_relative "datadog/exception_attribute_formatter"
