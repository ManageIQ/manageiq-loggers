if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require "bundler/setup"
require "manageiq-loggers"
require "rbconfig"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if RbConfig::CONFIG["host_os"] !~ /linux/
    config.filter_run_excluding(:linux => true)
  end
end

require "active_support"
puts
puts "\e[93mUsing ActiveSupport #{ActiveSupport.version}\e[0m"
