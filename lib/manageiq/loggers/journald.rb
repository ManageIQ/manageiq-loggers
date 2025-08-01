module ManageIQ
  module Loggers
    class Journald < Base
      # Create and return a new ManageIQ::Loggers::Journald instance. The
      # arguments to the initializer can be ignored unless you're multicasting.
      #
      # Internally we set our own formatter, and automatically set the
      # progname option to 'manageiq' if not specified.
      #
      def initialize(_logdev = nil, *_, **_)
        require "systemd-journal"
        super
        @formatter = Formatter.new
        @progname ||= 'manageiq'
      end

      # Comply with the VMDB::Logger interface. For a filename we simply use
      # the string 'journald' since we're not using a backing file directly.
      #
      def filename
        "journald"
      end

      # Redefine this method from the core Logger class. Internally this is
      # the method used when .info, .warn, etc are called.
      #
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

        message = formatter.call(format_severity(severity), nil, progname, message)

        # The call stack is different depending on if we are using the newer
        # ActiveSupport::BroadcastLogger or the older ActiveSupport::Logger.broadcast
        # so we have to account for that difference when walking up the caller_locations
        # to get the "real" logging location.
        caller_object = caller_locations.detect do |caller_loc|
          next if caller_loc.path.end_with?("lib/active_support/broadcast_logger.rb", "lib/active_support/logger.rb", "/logger.rb")

          caller_loc
        end

        Systemd::Journal.message(
          :message           => message,
          :priority          => log_level_map[severity],
          :syslog_identifier => progname,
          :code_line         => caller_object&.lineno,
          :code_file         => caller_object&.absolute_path,
          :code_func         => caller_object&.label
        )
      end

      private

      # Map the Systemd::Journal error levels to the Logger error levels. For
      # unknown, we go with alert level.
      #
      def log_level_map
        @log_level_map ||= {
          Logger::UNKNOWN => Systemd::Journal::LOG_ALERT,
          Logger::FATAL   => Systemd::Journal::LOG_CRIT,
          Logger::ERROR   => Systemd::Journal::LOG_ERR,
          Logger::WARN    => Systemd::Journal::LOG_WARNING,
          Logger::INFO    => Systemd::Journal::LOG_INFO,
          Logger::DEBUG   => Systemd::Journal::LOG_DEBUG,
        }
      end

      class Formatter < Base::Formatter
        def call(severity, _time, progname, msg)
          msg = prefix_task_id(msg2str(msg)).truncate(Base::MAX_LOG_LINE_LENGTH)
          "%5s -- %s: %s\n" % [severity, progname, msg]
        end
      end
    end
  end
end
