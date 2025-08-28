# frozen_string_literal: true

##
# Entry formatter for Datadog logs
# @!parse
#   class Lumberjack::Datadog::EntryFormatter < Lumberjack::EntryFormatter; end
module Lumberjack::Datadog
  # Formats log entries for Datadog
  class EntryFormatter < Lumberjack::EntryFormatter
    def initialize(backtrace_cleaner: nil)
      super()
      add_exception_formatter(backtrace_cleaner)
      add_duration_formatters
    end

    private

    def add_exception_formatter(backtrace_cleaner)
      add(Exception) do |error|
        Lumberjack::MessageAttributes.new(error.inspect, error: error)
      end

      attributes do
        add_class(Exception, Lumberjack::Datadog::ExceptionAttributeFormatter.new(backtrace_cleaner: backtrace_cleaner))
      end
    end

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
