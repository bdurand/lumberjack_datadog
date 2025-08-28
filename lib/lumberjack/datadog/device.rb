# frozen_string_literal: true

##
# Datadog device for Lumberjack logging
# @!parse
#   class Lumberjack::Datadog::Device < Lumberjack::JsonDevice; end
module Lumberjack::Datadog
  # Device for sending logs to Datadog
  class Device < Lumberjack::JsonDevice
    Lumberjack::DeviceRegistry.add(:datadog, self)

  # Initialize the Datadog device
  # @param options [Hash] Device options
  def initialize(options = {})
      datadog_options = options.dup
      datadog_options[:mapping] ||= Lumberjack::Datadog.json_mapping
      super(datadog_options)
    end
  end
end
