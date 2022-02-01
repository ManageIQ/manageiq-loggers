# ManageIQ::Loggers

[![Build Status](https://app.travis-ci.com/ManageIQ/manageiq-loggers.svg?branch=master)](https://app.travis-ci.com/ManageIQ/manageiq-loggers)
[![Maintainability](https://api.codeclimate.com/v1/badges/8d3c9bf77c45a024166b/maintainability)](https://codeclimate.com/github/ManageIQ/manageiq-loggers/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/8d3c9bf77c45a024166b/test_coverage)](https://codeclimate.com/github/ManageIQ/manageiq-loggers/test_coverage)

Loggers for ManageIQ projects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'manageiq-loggers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install manageiq-loggers

## Dependencies

Some loggers require additional gems to function correctly. These gems are not specified as dependencies of this gem directly because they may not be needed for all users of manageiq-loggers

To use the `Journald` logger, users must specify the `systemd-journal` gem as a dependency

To use the `CloudWatch` logger, users must specify the `cloudwatchlogger` gem as a dependency

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManageIQ/manageiq-loggers.

## License

This project is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).
