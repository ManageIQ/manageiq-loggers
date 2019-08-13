require 'active_support/core_ext/string'
require 'active_support/logger'

module ManageIQ
  module Loggers
    class CloudWatch < Base
      NAMESPACE_FILE = "/var/run/secrets/kubernetes.io/serviceaccount/namespace".freeze

      def self.new(*args)
        access_key_id     = ENV["CW_AWS_ACCESS_KEY_ID"].presence
        secret_access_key = ENV["CW_AWS_SECRET_ACCESS_KEY"].presence
        log_group_name    = ENV["CLOUD_WATCH_LOG_GROUP"].presence
        log_stream_name   = File.exist?(NAMESPACE_FILE) ? File.read(NAMESPACE_FILE) : nil

        container_logger = ManageIQ::Loggers::Container.new
        return container_logger unless access_key_id && secret_access_key && log_group_name && log_stream_name

        require 'cloudwatchlogger'

        creds = {:access_key_id => access_key_id, :secret_access_key => secret_access_key}
        cloud_watch_logdev = CloudWatchLogger::Client.new(creds, log_group_name, log_stream_name)
        super(cloud_watch_logdev).tap { |logger| logger.extend(ActiveSupport::Logger.broadcast(container_logger)) }
      end

      def initialize(logdev, *args)
        super
        self.formatter = ManageIQ::Loggers::Container::Formatter.new
      end
    end
  end
end
