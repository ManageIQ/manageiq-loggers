require "active_support"
require "active_support/deprecation"
require "active_support/json"

describe ManageIQ::Loggers::Container do
  let(:logger)  { described_class.new }
  let(:message) { "testing 1, 2, 3" }

  it "writes to STDOUT by default" do
    expect { logger.info(message) }.to output.to_stdout
  end

  it "#filename" do
    expect(logger.filename).to eq("STDOUT")
  end
end
