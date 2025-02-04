require "active_support"
require "active_support/deprecation"
require "active_support/json"

describe ManageIQ::Loggers::Container do
  let(:logger)  { described_class.new }
  let(:message) { "testing 1, 2, 3" }

  it "provides a default log device" do
    expect(described_class.new.logdev).to be_kind_of(Logger::LogDevice)
  end

  it "writes to STDOUT by default" do
    expect { logger.info(message) }.to output.to_stdout
  end

  it "#filename" do
    expect(logger.filename).to eq("STDOUT")
  end
end
