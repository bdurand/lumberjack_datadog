# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.0.0

### Added

- Support for Lumberjack 2.0.
- Added `Lumberjack::Datadog::Device` as a wrapper for `Lumberjack::JsonDevice` with mapping to Datadog standard attributes.
- Added `Lumberjack::Datadog::EntryFormatter` to encapsulate entry formatting logic for exceptions and duration. With Lumberjack 2 this can now be merged with other formatters.
- Added `Lumberjack::Datadog::ExceptionAttributeFormatter` to handle exception attribute extraction and formatting. This formatter can now also handle adding additional attributes from other kinds of exceptions.

### Changed

- **Breaking Change** Renamed gem from `lumberjack_data_dog` to `lumberjack_datadog` and renamed root module to `Lumberjack::Datadog`. This is just to remove confusion around the name convention.
- **Breaking Change** Tags are now called attributes in Lumberjack 2 so some of the method names for setting up attributes have changed.
  - `Lumberjack::Datadog::Config#allow_all_tags` is now `allow_all_attributes`.
  - `Lumberjack::Datadog::Config#tag_mapping` is now `attribute_mapping`.
  - `Lumberjack::Datadog#remap_tags` is now `remap_attributes`.
- Truncated messages are now suffixed with an ellipsis ("…") character.

### Removed

- Support for Ruby < 2.7

## 1.0.1

### Added

- Logger options can now be sent to `Lumberjack::Datadog.setup`.

## 1.0.0

### Added

- Initial release
