require 'manageiq/loggers/container'

describe ManageIQ::Loggers::Container::Formatter do
  let(:request_id) { "123" }
  let(:request) { double(:request_id => request_id) }
  before do
    Thread.current[:current_request] = request
  end
  after do
    Thread.current[:current_request] = nil
  end

  it "stuff" do
    time = Time.now
    result = described_class.new.call("INFO", time, "some_program", "testing 1, 2, 3")
    expected = {
      "@timestamp" => time.strftime("%Y-%m-%dT%H:%M:%S.%6N "),
      "hostname"   => ENV["HOSTNAME"],
      "level"      => "info",
      "message"    => "testing 1, 2, 3",
      "pid"        => $PROCESS_ID,
      "service"    => "some_program",
      "tid"        => Thread.current.object_id.to_s(16),
      "request_id" => request_id
    }.compact
    expect(JSON.parse(result)).to eq(expected)
  end
end
