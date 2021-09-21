# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.7.0...master
[0.7.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/ManageIQ/manageiq-loggers/compare/v0.1.0...v0.1.1
