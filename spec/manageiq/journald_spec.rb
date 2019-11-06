require 'manageiq/loggers/journald'

RSpec.describe ManageIQ::Loggers::Journald, :linux do
  let(:logger) { described_class.new }

  context "progname" do
    it "sets the progname to manageiq by default" do
      expect(logger.progname).to eql('manageiq')
    end
  end

  context "syslog_identifier accessor" do
    it "has a syslog_identifier accessor" do
      expect(logger).to respond_to(:syslog_identifier)
      expect(logger).to respond_to(:syslog_identifier=)
    end

    it "sets the syslog_identifier to the progname by default" do
      logger = ManageIQ::Loggers::Journald.new(nil, :progname => 'manageiq-test')
      expect(logger.syslog_identifier).to eql('manageiq-test')
    end
  end
end
