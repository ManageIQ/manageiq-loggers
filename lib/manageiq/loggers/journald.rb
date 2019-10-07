module ManageIQ
  module Loggers
    class Journald < Base
      # A UUID string that is used to identify the logger instance.
      attr_accessor :message_id

      # Create and return a new ManageIQ::Loggers::Journald instance. The
      # arguments to the initializer can be ignored unless you're multicasting.
      #
      # Internally we set our own formatter, as well as a single message ID
      # per instance, which is then passed on to journald as the MESSAGE_ID
      # attribute.
      #
      def initialize(logdev = nil, *args)
        require "systemd-journal"
        super(logdev, *args)
        self.formatter = Formatter.new
        self.message_id = SecureRandom.uuid.tr('-','')
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
        caller_object = caller_locations.last

        Systemd::Journal.message(
          :message           => message,
          :message_id        => message_id,
          :priority          => log_level_map[severity],
          :application       => 'cfme',
          :syslog_identifier => determine_identifier(message),
          :syslog_facility   => 'local3',
          :code_line         => caller_object.lineno,
          :code_file         => caller_object.absolute_path
        )
      end

      private

      # Determine the identifier based on the message. Ideally this would
      # be set by the provider once we have pluggable loggers, but for now
      # we parse the message.
      #
      def determine_identifier(message)
        case message
        when /Amazon/
          'cfme-aws'
        when /Azure/
          'cfme-azure'
        when /Google/
          'cfme-google'
        when /Kubernetes/
          'cfme-kubernetes'
        when /Kubevirt/
          'cfme-kubevirt'
        when /Microsoft/
          'cfme-scvmm'
        when /Nuage/
          'cfme-nuage'
        when /Openshift/
          'cfme-openshift'
        when /Openstack/
          'cfme-openstack'
        when /Redhat/
          'cfme-ovirt'
        when /Vmware/
          'cfme-vmware'
        else
          'cmfe'
        end
      end

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
