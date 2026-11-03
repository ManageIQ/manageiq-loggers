source "https://rubygems.org"

# Specify your gem's dependencies in manageiq-loggers.gemspec
gemspec

minimum_version =
  case ENV['TEST_RAILS_VERSION']
  when "8.0"
    "~>8.0.5"
  else
    "~>8.1.4"
  end

gem "activesupport", minimum_version
