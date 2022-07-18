module ManageIQ
  module Loggers
    class Container < JSONLogger
      def initialize(logdev = $stdout, *_, **_)
        logdev.sync = true # Don't buffer container log output
        super
      end

      def filename
        "STDOUT"
      end
    end
  end
end
