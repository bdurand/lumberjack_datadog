# frozen_string_literal: true

##
# Entry formatter for Datadog logs
# @!parse
#   class Lumberjack::Datadog::EntryFormatter < Lumberjack::EntryFormatter; end
module Lumberjack::Datadog
  # Formats log entries for Datadog with exception and duration handling.
  class EntryFormatter < Lumberjack::EntryFormatter
    # Initialize the entry formatter with Datadog-specific formatters.
    #
    # @param backtrace_cleaner [Object, nil] Optional backtrace cleaner that responds to #clean
    def initialize(backtrace_cleaner: nil)
      super()
      add_exception_formatter(backtrace_cleaner)
      add_duration_formatters
    end

    private

    # Add exception formatter that structures exceptions for Datadog.
    #
    # @param backtrace_cleaner [Object, nil] Optional backtrace cleaner
    # @return [void]
    def add_exception_formatter(backtrace_cleaner)
      add(Exception) do |error|
        Lumberjack::MessageAttributes.new(error.inspect, error: error)
      end

      attributes do
        add_class(Exception, Lumberjack::Datadog::ExceptionAttributeFormatter.new(backtrace_cleaner: backtrace_cleaner))
      end
    end

    # Add duration formatters that convert various duration units to nanoseconds.
    #
    # @return [void]
    def add_duration_formatters
      attributes do
        add_attribute(:duration) do |seconds|
          (seconds.to_f * 1_000_000_000).round
        end

        add_attribute(:duration_ms) do |millis|
          nanoseconds = (millis.to_f * 1_000_000).round
          Lumberjack::RemapAttribute.new("duration" => nanoseconds)
        end

        add_attribute(:duration_micros) do |micros|
          nanoseconds = (micros.to_f * 1_000).round
          Lumberjack::RemapAttribute.new("duration" => nanoseconds)
        end

        add_attribute(:duration_ns) do |ns|
          Lumberjack::RemapAttribute.new("duration" => ns.to_i)
        end
      end
    end
  end
end
