require "systemd-journal"

module ManageIQ
  module Loggers
    class Journald < Base
      def initialize(progname = nil)
        self.level     = INFO
        self.formatter = Formatter.new

        @local_levels = {}
      end

      def filename
        "journald"
      end

      def add(severity, message = nil, progname = nil)
        severity ||= Logger::UNKNOWN
        return true if severity < @level

        progname ||= @progname

        if message.nil?
          if block_given?
            message = yield
          else
            message = progname
            progname = @progname
          end
        end

        message = formatter.call(severity, message)

        Systemd::Journal.print(LOG_LEVEL_MAP[severity], message)
      end

      private

      LOG_LEVEL_MAP = {
        Logger::UNKNOWN => Systemd::Journal::LOG_ALERT,
        Logger::FATAL   => Systemd::Journal::LOG_CRIT,
        Logger::ERROR   => Systemd::Journal::LOG_ERR,
        Logger::WARN    => Systemd::Journal::LOG_WARNING,
        Logger::INFO    => Systemd::Journal::LOG_INFO,
        Logger::DEBUG   => Systemd::Journal::LOG_DEBUG,
      }

      class Formatter < Base::Formatter
        def call(severity, msg)
          prefix_task_id(msg2str(msg))
        end
      end
    end
  end
end
