module ManageIQ
  module Loggers
    class JSONLogger < Base
     def initialize(*_, **_)
        super
        self.formatter = Formatter.new
      end

      class Formatter < Base::Formatter
        SEVERITY_MAP = {
          "DEBUG"   => "debug",
          "INFO"    => "info",
          "WARN"    => "warning",
          "ERROR"   => "err",
          "FATAL"   => "crit",
          "UNKNOWN" => "unknown"
          # Others that don't match up: alert emerg notice trace
        }.freeze

        def initialize
          super
          require 'json'
        end

        def call(severity, time, progname, msg)
          # From https://github.com/ViaQ/elasticsearch-templates/releases -> Downloads -> *.asciidoc
          # NOTE: These values are in a specific order for easier human readbility via STDOUT
          payload = {
            :@timestamp => format_datetime(time),
            :hostname   => hostname,
            :pid        => $PROCESS_ID,
            :tid        => thread_id,
            :service    => progname,
            :level      => translate_error(severity),
            :message    => prefix_task_id(msg2str(msg)),
            :request_id => request_id
            # :tags => "tags string",
          }.compact
          JSON.generate(payload) << "\n"
        rescue Encoding::UndefinedConversionError
          raise unless msg.encoding == Encoding::ASCII_8BIT

          msg.force_encoding("UTF-8")
          retry
        end

        private

        def format_datetime(*)
          super.rstrip
        end

        def hostname
          @hostname ||= ENV["HOSTNAME"]
        end

        def thread_id
          Thread.current.object_id.to_s(16)
        end

        def translate_error(level)
          SEVERITY_MAP[level] || "unknown"
        end

        def request_id
          Thread.current[:request_id] || Thread.current[:current_request]&.request_id.tap do |request_id|
            if request_id
              require "active_support"
              require "active_support/deprecation"
              ActiveSupport::Deprecation.warn("Usage of `Thread.current[:current_request]&.request_id` will be deprecated in version 0.5.0. Please switch to `Thread.current[:request_id]` to log request_id automatically.")
            end
          end
        end
      end
    end
  end
end
