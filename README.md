# Lumberjack Datadog

[![Continuous Integration](https://github.com/bdurand/lumberjack_datadog/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/lumberjack_datadog/actions/workflows/continuous_integration.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/lumberjack_datadog.svg)](https://badge.fury.io/rb/lumberjack_datadog)

This gem provides a logging setup for using the [lumberjack](https://github.com/bdurand/lumberjack) gem with Datadog. It sets up JSON logging and maps values to Datadog's [standard attributes](https://docs.Datadoghq.com/logs/processing/attributes_naming_convention/).

## Features

- **Datadog Standard Attribute Mapping**: Automatically maps Lumberjack log fields to Datadog's standard attributes:
  - `time` → `timestamp`
  - `severity` → `status`
  - `progname` → `logger.name`
  - `pid` → `pid`
- **Exception Handling**: Structured exception logging with `kind`, `message`, and `stack` fields
- **Duration Logging**: Automatic conversion of duration values to nanoseconds for Datadog
- **Configurable Message Truncation**: Limit message length to prevent oversized logs
- **Thread Information**: Optional thread name logging
- **Attribute Remapping**: Flexible attribute transformation and remapping

## Usage

### Basic Setup

```ruby
require 'lumberjack_datadog'

# Create a logger that outputs to STDOUT
logger = Lumberjack::Datadog.setup

# Log messages
logger.info("Application started")
logger.warn("This is a warning", user_id: 123)
logger.error("Something went wrong", request_id: "abc-123")
```

### Advanced Configuration

```ruby
# The output device and logger options can be passed in the setup method.
# These are passed through to Lumberjack::Logger.new.
logger = Lumberjack::Datadog.setup(log_device, level: :info) do |config|
  # Truncate messages longer than 1000 characters
  config.max_message_length = 1000

  # Include thread information
  config.thread_name = true  # or :global for global thread ID

  # Disable PID logging
  config.pid = false

  # Remap custom attributes to Datadog attributes
  config.remap_attributes(
    user_id: "usr.id",
    request_id: "http.request_id"
  )

  # Add a backtrace cleaner to remove unnecessary noise when logging exceptions.
  # The cleaner object must respond to `clean` method.
  config.backtrace_cleaner = Rails.backtrace_cleaner

  # Enable pretty JSON for development
  config.pretty = true
end
```

TODO: regular configuration

### Logging to a File

```ruby
# Log to a file instead of STDOUT
logger = Lumberjack::Datadog.setup("/var/log/app.log")
logger.info("Logged to file")
```

### Exception Logging

Exceptions are automatically structured with Datadog's error attributes:

```ruby
begin
  raise StandardError, "Something went wrong"
rescue => e
  # Results in structured error with error.kind, error.message, and error.stack fields
  logger.error(e)
end
```

### Duration Logging

Duration values are automatically converted to nanoseconds:

```ruby
# Log execution time
start_time = Time.now
# ... do some work ...
duration = Time.now - start_time

logger.info("Operation completed", duration: duration)
# duration is automatically converted to nanoseconds

# You can also use specific duration units
logger.info("DB query", duration_ms: 150.5)      # milliseconds
logger.info("API call", duration_micros: 1500)   # microseconds
logger.info("Function", duration_ns: 1500000)    # nanoseconds
```

### Custom attribute Transformation

```ruby
logger = Lumberjack::Datadog.setup do |config|
  config.remap_attributes(
    # Simple remapping
    correlation_id: "trace.correlation_id",

    # Transform with a lambda
    user_email: ->(email) { {"usr.email" => email.downcase} }
  )
end

logger.info("User logged in", user_email: "USER@EXAMPLE.COM")
# Results in usr.email: "user@example.com"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "lumberjack_datadog"
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install lumberjack_datadog
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
