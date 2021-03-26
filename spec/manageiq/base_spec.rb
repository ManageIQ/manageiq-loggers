require 'manageiq/loggers/base'

describe ManageIQ::Loggers::Base do
  describe "#log_hashes" do
    let(:buffer) { StringIO.new }
    let(:logger) { described_class.new(buffer) }

    it "filters out passwords when keys are symbols" do
      hash = {:a => {:b => 1, :password => "pa$$w0rd"}}
      logger.log_hashes(hash)

      buffer.rewind
      expect(buffer.read).to include(":password: [FILTERED]")
    end

    it "filters out passwords when keys are strings" do
      hash = {"a" => {"b" => 1, "password" => "pa$$w0rd"}}
      logger.log_hashes(hash)

      buffer.rewind
      expect(buffer.read).to include("password: [FILTERED]")
    end

    it "with :filter option, filters out given keys and passwords" do
      hash = {:a => {:b => 1, :extra_key => "pa$$w0rd", :password => "pa$$w0rd"}}
      logger.log_hashes(hash, :filter => :extra_key)

      buffer.rewind
      message = buffer.read
      expect(message).to include(':extra_key: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when :filter option is a Set object, filters out the given Set elements" do
      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}
      logger.log_hashes(hash, :filter => %i(bind_pwd password amazon_secret).to_set)

      buffer.rewind
      message = buffer.read
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "filters out encrypted value" do
      hash = {:a => {:b => 1, :extra_key => "v2:{c5qTeiuz6JgbBOiDqp3eiQ==}"}}
      logger.log_hashes(hash)

      buffer.rewind
      expect(buffer.read).to include(':extra_key: [FILTERED]')
    end

    it "filters out root_password" do
      hash = {"a" => {"b" => 1, "root_password" => "pa$$w0rd"}}
      logger.log_hashes(hash)

      buffer.rewind
      expect(buffer.read).to include("root_password: [FILTERED]")
    end

    it "filters out password_for_important_thing" do
      hash = {:a => {:b => 1, :password_for_important_thing => "pa$$w0rd"}}
      logger.log_hashes(hash)

      buffer.rewind
      expect(buffer.read).to include(":password_for_important_thing: [FILTERED]")
    end

    it "handles logging hash-like classes" do
      require "active_support/core_ext/hash"
      hash = ActiveSupport::HashWithIndifferentAccess.new(:a => 1, :b => {:c => 3})
      logger.log_hashes(hash)

      buffer.rewind
      expect(buffer.read).to include(<<-EOS)
---
a: 1
b:
  c: 3
      EOS
    end
  end

  context "long messages" do
    let(:logger) { described_class.new(@log) }

    it "truncates long messages when max_message_size is set" do
      msg = "a" * 10.kilobytes
      _, message = logger.formatter.call(:error, Time.now.utc, "", msg).split("-- : ")
      expect(message.strip.size).to eq(8.kilobytes)
    end
  end
end
