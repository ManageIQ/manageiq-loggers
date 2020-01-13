require 'cloudwatchlogger'
require 'manageiq/loggers/cloud_watch'

describe ManageIQ::Loggers::CloudWatch do
  it "unconfigured returns a Container logger" do
    expect(described_class.new).to be_kind_of(ManageIQ::Loggers::Container)
  end

  context "configured" do
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
      expect(CloudWatchLogger::Client::AWS_SDK::DeliveryThreadManager).to receive(:new).and_return(double("CloudWatchLogger::Client::AWS_SDK::DeliveryThreadManager", :deliver => nil))
    end

    it "returns a CloudWatch::Client" do
      expect(described_class.new).to be_kind_of(ManageIQ::Loggers::CloudWatch)
    end

    it "the Container logger also receives the same messages" do
      container_logger = ManageIQ::Loggers::Container.new
      expect(ManageIQ::Loggers::Container).to receive(:new).and_return(container_logger)

      expect(container_logger).to receive(:add).with(1, nil, "Testing 1,2,3")

      described_class.new.info("Testing 1,2,3")
    end
  end
end
