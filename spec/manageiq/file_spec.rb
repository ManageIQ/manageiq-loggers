require 'tempfile'

describe ManageIQ::Loggers::File do
  let(:log_file) { Tempfile.new(['test_log', '.log']) }
  let(:logger) { described_class.new(log_file.path) }

  after do
    log_file.close
    log_file.unlink
  end

  describe "#contents" do
    context "with an empty file" do
      it "returns an empty array" do
        expect(logger.contents).to eq([])
      end
    end

    context "with a file containing lines" do
      before do
        10.times { |i| logger.info("Line #{i + 1}") }
        logger.close
      end

      it "returns the last N lines by default (100)" do
        result = logger.contents
        expect(result).to be_an(Array)
        expect(result.size).to eq(10)
      end

      it "returns the specified number of lines" do
        result = logger.contents(5)
        expect(result.size).to eq(5)
        expect(result.last).to include("Line 10")
      end

      it "returns all lines when line_count exceeds file size" do
        result = logger.contents(1000)
        expect(result.size).to eq(10)
      end

      it "returns all lines when line_count is nil" do
        result = logger.contents(nil)
        expect(result.size).to eq(10)
      end

      it "reads a full line if ending on a buffer_size boundary" do
        buffer_size = File.size(logger.logdev.filename) - 10
        expect(logger.contents(10, buffer_size)).to match_array(logger.contents)
      end

      it "returns lines in correct order" do
        result = logger.contents(3)
        expect(result[0]).to include("Line 8")
        expect(result[1]).to include("Line 9")
        expect(result[2]).to include("Line 10")
      end
    end

    context "with Unicode characters" do
      before do
        logger.info("häåğēn.däzş")
        logger.info("日本語テスト")
        logger.info("Тест кириллицы")
        logger.close
      end

      it "handles UTF-8 encoded content correctly" do
        result = logger.contents
        expect(result.size).to eq(3)
        expect(result[0]).to include("häåğēn.däzş")
        expect(result[1]).to include("日本語テスト")
        expect(result[2]).to include("Тест кириллицы")
      end
    end

    context "with a large file" do
      before do
        500.times { |i| logger.info("Line #{i + 1}") }
        logger.close
      end

      it "efficiently reads from the end" do
        result = logger.contents(50)
        expect(result.size).to eq(50)
        expect(result.first).to include("Line 451")
        expect(result.last).to include("Line 500")
      end

      it "handles reading more lines than buffer size" do
        result = logger.contents(200)
        expect(result.size).to eq(200)
        expect(result.first).to include("Line 301")
        expect(result.last).to include("Line 500")
      end
    end

    context "when file does not exist initially" do
      let(:nonexistent_path) { '/tmp/nonexistent_test_file.log' }
      let(:logger) { described_class.new(nonexistent_path) }

      after do
        FileUtils.rm_f(nonexistent_path)
      end

      it "returns only the logger header line" do
        result = logger.contents
        expect(result.size).to eq(1)
        expect(result.first).to include("Logfile created")
      end
    end

    context "with single line" do
      before do
        logger.info("Single line")
        logger.close
      end

      it "returns the single line" do
        result = logger.contents
        expect(result.size).to eq(1)
        expect(result.first).to include("Single line")
      end
    end

    context "with lines containing special characters" do
      before do
        logger.info("Line with\ttabs")
        logger.info("Line with\nnewline escape")
        logger.info("Line with \"quotes\"")
        logger.close
      end

      it "preserves special characters" do
        result = logger.contents
        expect(result.size).to eq(4) # newline escape creates an extra line
        expect(result[0]).to include("Line with\ttabs")
      end
    end
  end
end
