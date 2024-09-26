source "https://rubygems.org"

# Specify your gem's dependencies in manageiq-loggers.gemspec
gemspec

minimum_version =
  case ENV['TEST_RAILS_VERSION']
  when "6.1"
    "~>6.1.7"
  else
    "~>7.0.8"
  end

gem "activesupport", minimum_version
