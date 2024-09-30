require 'cloudwatchlogger'

describe ManageIQ::Loggers::CloudWatch do
  let(:cloud_watch_logdev) { double("CloudWatchLogger::Client::AWS_SDK::DeliveryThreadManager") }

  it "raises an exception if cloudwatch parameters are missing" do
    expect { described_class.new }.to raise_error(ArgumentError, /Required parameters: access_key_id, secret_access_key, log_group, log_stream/)
  end

  context "configured via env" do
    around do |example|
      ENV["CW_AWS_ACCESS_KEY_ID"] = "test"
      ENV["CW_AWS_SECRET_ACCESS_KEY"] = "test"
      ENV["CLOUD_WATCH_LOG_GROUP"] = "test"
      old_hostname = ENV["HOSTNAME"]
      ENV["HOSTNAME"] = "test"

      example.run

      ENV.delete("CW_AWS_ACCESS_KEY_ID")
      ENV.delete("CW_AWS_SECRET_ACCESS_KEY")
      ENV.delete("CLOUD_WATCH_LOG_GROUP")
      old_hostname.nil? ? ENV.delete("HOSTNAME") : ENV["HOSTNAME"] = old_hostname
    end

    before do
      expect(CloudWatchLogger::Client::AWS_SDK::DeliveryThreadManager)
        .to receive(:new)
        .and_return(cloud_watch_logdev)
    end

    it "calls deliver on the CloudWatch logger" do
      expect(cloud_watch_logdev).to receive(:deliver).with(a_string_matching("\"level\":\"info\",\"message\":\"Testing 1,2,3\""))
      described_class.new.info("Testing 1,2,3")
    end
  end

  context "configured via params" do
    let(:params) do
      {
        access_key_id: 'test',
        secret_access_key: 'test',
        log_group: 'test',
        log_stream: 'test'
      }
    end

    before do
      expect(CloudWatchLogger::Client::AWS_SDK::DeliveryThreadManager)
        .to receive(:new)
        .and_return(cloud_watch_logdev)
    end

    it "calls deliver on the CloudWatch logger" do
      expect(cloud_watch_logdev).to receive(:deliver).with(a_string_matching("\"level\":\"info\",\"message\":\"Testing 1,2,3\""))
      described_class.new(**params).info("Testing 1,2,3")
    end
  end
end
