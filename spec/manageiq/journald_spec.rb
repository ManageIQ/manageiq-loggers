RSpec.describe ManageIQ::Loggers::Journald do
  let!(:logger) do
    described_class.new
  rescue LoadError
    raise if RbConfig::CONFIG['host_os'].match?(/linux/i) # We expect this to be available on linux, so raise

    skip "systemd-journal is not available on this system (#{RbConfig::CONFIG['host_os']})"
  end

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
      expect(Systemd::Journal).to receive(:message).with(hash_including(:code_file => __FILE__, :code_line => __LINE__ + 1))
      logger.info("abcd") # NOTE: this has to be exactly beneath the exect for the __LINE__ + 1 to work
    end

    context "with a wrapped logger" do
      let(:log) { logger.wrap(Logger.new(IO::NULL)) }

      it "sets the code_file" do
        expect(Systemd::Journal).to receive(:message).with(hash_including(:code_file => __FILE__, :code_line => __LINE__ + 1))
        log.info("abcd") # NOTE: this has to be exactly beneath the exect for the __LINE__ + 1 to work
      end
    end
  end

  describe "#contents" do
    let(:journal) { instance_double("Systemd::Journal") }

    let(:entries) do
      [
        double(
          :_source_realtime_timestamp => "1715000000000000",
          :_pid                       => 123,
          :message                    => " INFO -- manageiq: Line 1\n"
        ),
        double(
          :_source_realtime_timestamp => "1715000001000000",
          :_pid                       => 456,
          :message                    => " WARN -- manageiq: Line 2\n"
        ),
        double(
          :_source_realtime_timestamp => "1715000002000000",
          :_pid                       => 789,
          :message                    => "ERROR -- manageiq: Line 3\n"
        )
      ]
    end

    before do
      allow(Systemd::Journal).to receive(:open).and_yield(journal)
      allow(journal).to receive(:filter)
      allow(journal).to receive(:seek)
    end

    it "filters by progname and seeks to tail" do
      allow(journal).to receive(:move_previous).and_return(false)

      logger.contents

      expect(journal).to have_received(:filter).with(:syslog_identifier => "manageiq")
      expect(journal).to have_received(:seek).with(:tail)
    end

    it "returns entries in chronological order" do
      current_entry = nil
      allow(journal).to receive(:move_previous) do
        current_entry = entries.pop
        !current_entry.nil?
      end
      allow(journal).to receive(:current_entry) { current_entry }

      result = Time.use_zone("Eastern Time (US & Canada)") { logger.contents }
      expected = [
         "[2024-05-06T08:53:20.000000-04:00 #123]  INFO -- manageiq: Line 1\n",
         "[2024-05-06T08:53:21.000000-04:00 #456]  WARN -- manageiq: Line 2\n",
         "[2024-05-06T08:53:22.000000-04:00 #789] ERROR -- manageiq: Line 3\n"
       ]

      expect(result).to eq(expected)
    end

    it "returns at most the requested number of entries" do
      current_entry = nil
      available_entries = entries.dup
      allow(journal).to receive(:move_previous) do
        current_entry = available_entries.pop
        !current_entry.nil?
      end
      allow(journal).to receive(:current_entry) { current_entry }

      result = logger.contents(2)

      expect(result.size).to eq(2)
      expect(result.first).to include("Line 2")
      expect(result.last).to include("Line 3")
    end

    it "returns all entries if there are fewer than the number requested" do
      current_entry = nil
      available_entries = entries.dup
      allow(journal).to receive(:move_previous) do
        current_entry = available_entries.pop
        !current_entry.nil?
      end
      allow(journal).to receive(:current_entry) { current_entry }

      result = logger.contents(10)

      expect(result.size).to eq(3)
      expect(result.first).to include("Line 1")
      expect(result.last).to include("Line 3")
    end

    it "returns an empty array when there are no matching entries" do
      allow(journal).to receive(:move_previous).and_return(false)

      expect(logger.contents).to eq([])
    end

    it "returns all entries when max_count is nil" do
      current_entry = nil
      available_entries = entries.dup
      allow(journal).to receive(:move_previous) do
        current_entry = available_entries.pop
        !current_entry.nil?
      end
      allow(journal).to receive(:current_entry) { current_entry }

      result = logger.contents(nil)

      expect(result.size).to eq(3)
    end
  end
end
