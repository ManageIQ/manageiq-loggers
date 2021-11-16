RSpec.describe ManageIQ::Loggers::Journald, :linux do
  let(:logger) { described_class.new }

  context "progname" do
    it "sets the progname to manageiq by default" do
      expect(logger.progname).to eq("manageiq")
    end

    it "allows progname overrides" do
      logger.progname = "manageiq-test"
      expect(logger.progname).to eq("manageiq-test")
    end

    it "allows progname overrides on instantiation" do
      logger = described_class.new(nil, :progname => "manageiq-test")
      expect(logger.progname).to eq("manageiq-test")
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
