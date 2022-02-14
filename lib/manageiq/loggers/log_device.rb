module ManageIQ
  module Loggers
    class LogDevice < Logger::LogDevice
      def initialize(*args, perm: 0o644, owner_uid: nil, owner_gid: nil)
        @perm      = perm
        @owner_uid = owner_uid
        @owner_gid = owner_gid

        super(*args)
      end

      private

      def create_logfile(filename)
        super.tap do |logdev|
          logdev.chmod(@perm) if @perm

          begin
            File.chown(@owner_uid, @owner_gid, filename) if @owner_uid || @owner_gid
          rescue Errno::EPERM
          end
        end
      end
    end
  end
end
