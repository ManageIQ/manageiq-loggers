require 'manageiq/loggers/container'

describe ManageIQ::Loggers::Container::Formatter do
  let(:message) { "testing 1, 2, 3" }

  def expected_hash(time, message, request_id = nil)
    {
      "@timestamp" => time.strftime("%Y-%m-%dT%H:%M:%S.%6N "),
      "hostname"   => ENV["HOSTNAME"],
      "level"      => "info",
      "message"    => message,
      "pid"        => $PROCESS_ID,
      "service"    => "some_program",
      "tid"        => Thread.current.object_id.to_s(16),
      "request_id" => request_id
    }.compact
  end

  describe "with a request_id in thread local storage" do
    let(:request_id) { "123" }

    context "in :request_id" do
      before { Thread.current[:request_id] = request_id }
      after  { Thread.current[:request_id] = nil }

      it do
        time = Time.now
        result = described_class.new.call("INFO", time, "some_program", message)
        expected = expected_hash(time, message, request_id)
        expect(JSON.parse(result)).to eq(expected)
      end
    end

    context "in deprecated :current_request" do
      before { Thread.current[:current_request] = double(:request_id => request_id) }
      after  { Thread.current[:current_request] = nil }

      it do
        require "active_support/deprecation"
        expect(ActiveSupport::Deprecation).to receive(:warn)

        time = Time.now
        result = described_class.new.call("INFO", time, "some_program", message)
        expected = expected_hash(time, message, request_id)
        expect(JSON.parse(result)).to eq(expected)
      end
    end
  end

  it "logs a message" do
    time = Time.now
    result = described_class.new.call("INFO", time, "some_program", message)
    expected = expected_hash(time, message)
    expect(JSON.parse(result)).to eq(expected)
  end
end
