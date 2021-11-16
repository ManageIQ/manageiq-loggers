require "active_support/core_ext/module/aliasing"
require "active_support/deprecation"

module ManageIQ
  module Loggers
    class Journald < Base
      alias_attribute :syslog_identifier, :progname
      ActiveSupport::Deprecation.new('v1.0', 'manageiq-loggers').deprecate_methods(self,
        :syslog_identifier  => :progname,
        :syslog_identifier= => :progname=,
      )

      # Create and return a new ManageIQ::Loggers::Journald instance. The
      # arguments to the initializer can be ignored unless you're multicasting.
      #
      # Internally we set our own formatter, and automatically set the
      # progname option to 'manageiq' if not specified.
      #
      def initialize(logdev = nil, *args)
        require "systemd-journal"
        super(logdev, *args)
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

        message = formatter.call(format_severity(severity), progname, message)
        caller_object = caller_locations(3, 1).first

        Systemd::Journal.message(
          :message           => message,
          :priority          => log_level_map[severity],
          :syslog_identifier => progname,
          :code_line         => caller_object.lineno,
          :code_file         => caller_object.absolute_path,
          :code_func         => caller_object.label
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
        def call(severity, progname, msg)
          msg = prefix_task_id(msg2str(msg)).truncate(Base::MAX_LOG_LINE_LENGTH)
          "%5s -- %s: %s\n" % [severity, progname, msg]
        end
      end
    end
  end
end
