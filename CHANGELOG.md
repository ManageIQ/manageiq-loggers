# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.2.0] - 2024-09-30
### Added
- Test with ruby 3.1 and 3.0 [(#65)](https://github.com/ManageIQ/manageiq-loggers/pull/65)
- Add ActiveSupport versions into the test matrix [(#77)](https://github.com/ManageIQ/manageiq-loggers/pull/77)
- Add a wrap method to support BroadcastLogger [(#63)](https://github.com/ManageIQ/manageiq-loggers/pull/63)

## [1.1.1] - 2023-12-13
### Fixed
- Fix Journald::Formatter's arguments list [(#61)](https://github.com/ManageIQ/manageiq-loggers/pull/61)
- Fix missing ActiveSupport::Logger.broadcast [(#62)](https://github.com/ManageIQ/manageiq-loggers/pull/62)

### Changed
- Update actions/checkout version to v4 [(#60)](https://github.com/ManageIQ/manageiq-loggers/pull/60)
- Update GitHub Actions versions [(#59)](https://github.com/ManageIQ/manageiq-loggers/pull/59)

## [1.1.0] - 2022-11-14
### Changed
- Split out JSON logger from Container logger [(#49)](https://github.com/ManageIQ/manageiq-loggers/pull/49)
- Allow passing the CloudWatch logger's configuration as kwargs [(#50)](https://github.com/ManageIQ/manageiq-loggers/pull/50)

### Fixed
- Remove timestamp whitespace in container logger formatter [(#47)](https://github.com/ManageIQ/manageiq-loggers/pull/47)

## [1.0.1] - 2021-01-05
### Fixed
- Fix require issue when used with Rails 7 [(#42)](https://github.com/ManageIQ/manageiq-loggers/pull/42)
- Check if the global is defined before trying to use it for Ruby 3 support [(#41)](https://github.com/ManageIQ/manageiq-loggers/pull/41)

## [1.0.0] - 2021-11-16
### Removed
- **BREAKING** Remove support for Ruby 2.4 and 2.5 [(#40)](https://github.com/ManageIQ/manageiq-loggers/pull/40)

### Fixed
- Fixed Ruby 3 support with kwargs [(#40)](https://github.com/ManageIQ/manageiq-loggers/pull/40)

## [0.8.0] - 2021-11-15
### Changed
- Add Ruby 2.6, 2.7, and 3.0 support [(#38)](https://github.com/ManageIQ/manageiq-loggers/pull/38)
- Add ability to set class-level and instance-level filters for log_hashes [(#38)](https://github.com/ManageIQ/manageiq-loggers/pull/38)

## [0.7.0] - 2021-09-21
### Changed
- Truncate log lines to 8Kb [(#32)](https://github.com/ManageIQ/manageiq-loggers/pull/32)
- Honor container log level [(#35)](https://github.com/ManageIQ/manageiq-loggers/pull/35)
- Use progname rather than syslog_identifier for journald logs [(#36)](https://github.com/ManageIQ/manageiq-loggers/pull/36)

### Fixed
- Handle Unicode characters in binary messages. [(#34)](https://github.com/ManageIQ/manageiq-loggers/pull/34)

## [0.6.0] - 2020-12-09
### Changed
- Update rake dependency to address CVE-2020-8130 [(#19)](https://github.com/ManageIQ/manageiq-loggers/pull/19)

### Fixed
- Fix escaping of < and > in Container logger [(#29)](https://github.com/ManageIQ/manageiq-loggers/pull/29)
- Fix ActiveSupport::Deprecation call [(#29)](https://github.com/ManageIQ/manageiq-loggers/pull/29)
- Fix the handling of journald code_file/code_line [(#21)](https://github.com/ManageIQ/manageiq-loggers/pull/21) [(#22)](https://github.com/ManageIQ/manageiq-loggers/pull/22)

### Added
- Add code_func to the journald logger [(#23)](https://github.com/ManageIQ/manageiq-loggers/pull/23)

## [0.5.0] - 2020-03-18
### Changed
- Deprecate Thread.current[:current_request]&.request_id in favor of Thread.current[:request_id] [(#17)](https://github.com/ManageIQ/manageiq-loggers/pull/17)

## [0.4.2] - 2020-01-14
### Fixed
- Revert "Change CloudWatch log_group to be the namespace if it exists" [(#16)](https://github.com/ManageIQ/manageiq-loggers/pull/16)

## [0.4.1] - 2020-01-06
### Fixed
- Change CloudWatch logger log_group and log_stream values for easier debugging and unique identifiers [(#15)](https://github.com/ManageIQ/manageiq-loggers/pull/15)
- Enhancements to the journald logger to allow for easier debugging [(#11)](https://github.com/ManageIQ/manageiq-loggers/pull/11)

## [0.4.0] - 2019-08-15
### Changed
- The Cloud Watch logger will now also broadcast its log messages to the container logger [(#10)](https://github.com/ManageIQ/manageiq-loggers/pull/10)

## [0.3.0] - 2019-05-30
### Added
- Add a Journald Logger [(#5)](https://github.com/ManageIQ/manageiq-loggers/pull/5)
- Add a cloud watch logger [(#9)](https://github.com/ManageIQ/manageiq-loggers/pull/9)

## [0.2.0] - 2019-05-03
### Added
- Log the request id in the container logger if present [(#7)](https://github.com/ManageIQ/manageiq-loggers/pull/7)

## [0.1.1] - 2019-02-27
### Fixed
- Always sync container STDOUT logs [(#4)](https://github.com/ManageIQ/manageiq-loggers/pull/4)

## [0.1.0] - 2019-01-08

[Unreleased]: https://github.com/ManageIQ/manageiq-loggers/compare/v1.2.0...master
[1.2.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/ManageIQ/manageiq-loggers/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/ManageIQ/manageiq-loggers/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.8.0...v1.0.0
[0.8.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.1.0...v0.1.1
