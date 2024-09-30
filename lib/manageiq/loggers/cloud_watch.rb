require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/logger'

module ManageIQ
  module Loggers
    class CloudWatch < Base
      NAMESPACE_FILE = "/var/run/secrets/kubernetes.io/serviceaccount/namespace".freeze

      def self.new(*args, access_key_id: nil, secret_access_key: nil, log_group: nil, log_stream: nil)
        access_key_id     ||= ENV["CW_AWS_ACCESS_KEY_ID"].presence
        secret_access_key ||= ENV["CW_AWS_SECRET_ACCESS_KEY"].presence
        log_group         ||= ENV["CLOUD_WATCH_LOG_GROUP"].presence
        log_stream        ||= ENV["HOSTNAME"].presence

        raise ArgumentError, "Required parameters: access_key_id, secret_access_key, log_group, log_stream" unless access_key_id && secret_access_key && log_group && log_stream

        require 'cloudwatchlogger'

        creds = {:access_key_id => access_key_id, :secret_access_key => secret_access_key}
        cloud_watch_logdev = CloudWatchLogger::Client.new(creds, log_group, log_stream)
        super(cloud_watch_logdev)
      end

      def initialize(logdev, *args)
        super
        self.formatter = ManageIQ::Loggers::Container::Formatter.new
      end
    end
  end
end
