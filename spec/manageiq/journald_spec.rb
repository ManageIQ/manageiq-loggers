RSpec.describe ManageIQ::Loggers::Journald, :linux do
  let(:logger) { described_class.new }

  context "progname" do
    it "has a progname accessor" do
      expect(logger).to respond_to(:progname)
      expect(logger).to respond_to(:progname=)
    end

    it "sets the progname to manageiq by default" do
      expect(logger.progname).to eql('manageiq')
    end
  end

  context "code_file" do
    it "sets the code_file" do
      log = Logger.new(IO::NULL)
      log.extend(ActiveSupport::Logger.broadcast(logger))

      expect(Systemd::Journal).to receive(:message).with(hash_including(:code_file => __FILE__, :code_line => __LINE__ + 1))
      log.info("abcd") # NOTE this has to be exactly beneath the exect for the __LINE__ + 1 to work
    end
  end
end
