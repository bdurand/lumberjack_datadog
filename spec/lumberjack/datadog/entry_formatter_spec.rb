# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lumberjack::Datadog::EntryFormatter do
  let(:stream) { StringIO.new }
  let(:last_entry) { JSON.parse(stream.string.split("\n").last) }

  describe "duration" do
    it "transforms duration to nanoseconds" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message", duration: 1.1)
      expect(last_entry["duration"]).to eq(1_100_000_000)
    end

    it "transforms duration to milliseconds" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message", duration_ms: 1.1)
      expect(last_entry["duration"]).to eq(1_100_000)
    end

    it "transforms duration to microseconds" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message", duration_micros: 1.1)
      expect(last_entry["duration"]).to eq(1_100)
    end

    it "transforms duration to nanoseconds" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message", duration_ns: 1.1)
      expect(last_entry["duration"]).to eq(1)
    end
  end

  describe "exceptions" do
    it "logs exceptions under the error attribute" do
      logger = Lumberjack::Datadog.setup(stream)
      begin
        raise "Test exception"
      rescue => e
        logger.error("An error occurred", error: e)
      end
      expect(last_entry["error"]["kind"]).to eq("RuntimeError")
      expect(last_entry["error"]["message"]).to eq("Test exception")
      expect(last_entry["error"]["stack"]).to eq(e.backtrace)
    end

    it "formats exceptions in the attributes in to kind, message, and stack subfields" do
      logger = Lumberjack::Datadog.setup(stream)
      begin
        raise "Test exception"
      rescue => e
        logger.error("An error occurred", exception: e)
      end
      expect(last_entry["exception"]["kind"]).to eq("RuntimeError")
      expect(last_entry["exception"]["message"]).to eq("Test exception")
      expect(last_entry["exception"]["stack"]).to eq(e.backtrace)
    end
  end
end
