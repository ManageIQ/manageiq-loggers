describe ManageIQ::Loggers::JSONLogger do
  let(:buffer)  { StringIO.new }
  let(:logger)  { described_class.new(buffer) }
  let(:message) { "testing 1, 2, 3" }

  it "provides nil default log device" do
    expect(described_class.new.logdev).to eq nil
  end

  it "logs a message in JSON format" do
    logger.info(message)

    parsed = JSON.parse(buffer.string)
    expected = {
      "@timestamp" => a_string_matching(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}$/),
      "pid"        => $PROCESS_ID,
      "tid"        => Thread.current.object_id.to_s(16),
      "level"      => "info",
      "message"    => "testing 1, 2, 3",
    }

    expect(parsed).to      match(expected)
    expect(parsed.keys).to eq(expected.keys) # Verifying the key order and no extra keys
  end

  it "logs service if available" do
    logger.progname = "some service"

    logger.info(message)

    parsed = JSON.parse(buffer.string)
    expected = {
      "@timestamp" => a_string_matching(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{6}$/),
      "pid"        => $PROCESS_ID,
      "tid"        => Thread.current.object_id.to_s(16),
      "service"    => "some service",
      "level"      => "info",
      "message"    => "testing 1, 2, 3",
    }

    expect(parsed).to      match(expected)
    expect(parsed.keys).to eq(expected.keys) # Verifying the key order and no extra keys
  end
end
