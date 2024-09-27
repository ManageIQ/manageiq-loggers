require "manageiq/loggers/base"
require "manageiq/loggers/json_logger"

require "manageiq/loggers/cloud_watch"
require "manageiq/loggers/container"
require "manageiq/loggers/journald"

require "manageiq/loggers/version"

module ManageIQ
  module Loggers
    def self.deprecator
      @deprecator ||= ActiveSupport::Deprecation.new(VERSION, "ManageIQ::Loggers")
    end
  end
end
