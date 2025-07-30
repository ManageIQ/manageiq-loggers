source "https://rubygems.org"

# Specify your gem's dependencies in manageiq-loggers.gemspec
gemspec

minimum_version =
  case ENV['TEST_RAILS_VERSION']
  when "7.2"
    "~>7.2.2"
  else
    "~>7.1.5"
  end

gem "activesupport", minimum_version
