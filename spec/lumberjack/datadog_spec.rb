# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lumberjack::Datadog do
  let(:stream) { StringIO.new }
  let(:last_entry) { JSON.parse(stream.string.split("\n").last) }

  describe "options" do
    it "passes options through to Lumberjack::Logger" do
      logger = Lumberjack::Datadog.setup(stream, level: :warn)
      expect(logger.level).to eq(Logger::WARN)
    end
  end

  describe "json_mapping" do
    it "logs the time as timestamp" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message")
      expect(Time.iso8601(last_entry["timestamp"])).to be_a(Time)
    end

    it "logs the severity as status" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message")
      expect(last_entry["status"]).to eq("INFO")
    end

    it "logs the progname as logger.name" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.progname = "TestLogger"
      logger.info("Test message")
      expect(last_entry["logger"]["name"]).to eq("TestLogger")
    end
  end

  describe "pid" do
    it "logs the pid" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message")
      expect(last_entry["pid"]).to eq(Process.pid)
    end

    it "can log the pid with a global value" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.pid = :global
      end
      logger.info("Test message")
      expect(last_entry["pid"]).to eq(Lumberjack::Utils.global_pid)
    end

    it "can remove the pid" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.pid = false
      end
      logger.info("Test message")
      expect(last_entry).not_to include("pid")
    end
  end

  describe "logger.thread" do
    it "does not log thread name by default" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message")
      expect(last_entry).not_to include("logger.thread_name")
    end

    it "can log a thread name" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.thread_name = true
      end
      logger.info("Test message")
      expect(last_entry["logger"]["thread_name"]).to eq(Lumberjack::Utils.thread_name)
    end

    it "can log a global thread name" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.thread_name = :global
      end
      logger.info("Test message")
      expect(last_entry["logger"]["thread_name"]).to eq(Lumberjack::Utils.global_thread_id)
    end
  end

  describe "attributes" do
    it "shows all attributes by default" do
      logger = Lumberjack::Datadog.setup(stream)
      logger.info("Test message", test: "value")
      expect(last_entry["test"]).to eq("value")
    end

    it "can remap attributes" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.remap_attributes(test: "foo")
      end
      logger.info("Test message", test: "value")
      expect(last_entry["foo"]).to eq("value")
    end

    it "can remap attributes with a formatter" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.remap_attributes(test: ->(value) { {"test" => "formatted_#{value}"} })
      end
      logger.info("Test message", test: "value")
      expect(last_entry["test"]).to eq("formatted_value")
    end
  end

  describe "message trunction" do
    it "can truncate long messages" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.max_message_length = 10
      end
      logger.info("012345678901234567890")
      expect(last_entry["message"]).to eq("0123456789")
    end

    it "does not truncate messages if max_message_length set to nil" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.max_message_length = nil
      end
      logger.info("012345678901234567890")
      expect(last_entry["message"]).to eq("012345678901234567890")
    end
  end

  describe "pretty" do
    it "can log pretty JSON" do
      logger = Lumberjack::Datadog.setup(stream) do |config|
        config.pretty = true
      end
      logger.info("Test message")
      expect(stream.string.split("\n").length).to be > 3
    end
  end
end
