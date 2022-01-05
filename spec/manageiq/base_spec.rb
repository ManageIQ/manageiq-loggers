require 'manageiq/loggers/base'

describe ManageIQ::Loggers::Base do
  let(:buffer)  { StringIO.new }
  let(:logger)  { described_class.new(buffer) }
  let(:message) { "testing 1, 2, 3" }

  after do
    # Clear any cached class-level filters
    described_class.instance_variable_set("@log_hashes_filter", nil)
  end

  it "logs a message" do
    logger.info(message)

    expect(buffer.string).to include(message)
  end

  it "logs a message with Unicode characters" do
    message = "häåğēn.däzş"
    result = logger.info(message)

    expect(buffer.string).to include(message)
  end

  it "logs a message with ASCII-8BIT encoding" do
    result = logger.info(message.dup.force_encoding("ASCII-8BIT"))

    expect(buffer.string).to include(message)
  end

  it "logs a message with ASCII-8BIT encoding and Unicode characters" do
    message = "häåğēn.däzş"
    result = logger.info(message.dup.force_encoding("ASCII-8BIT"))

    expect(buffer.string).to include(message)
  end

  shared_examples_for "log_hashes_filter / log_hashes_filter=" do
    it "defaults to include password" do
      expect(subject.log_hashes_filter).to eq %w[password]
    end

    it "accepts strings" do
      subject.log_hashes_filter = %w[extra_key]

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end

    it "accepts symbols" do
      subject.log_hashes_filter = %i[extra_key]

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end

    it "accepts single element" do
      subject.log_hashes_filter = :extra_key

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end

    it "accepts duplicates" do
      subject.log_hashes_filter = %i[extra_key extra_key password]

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end

    it "accepts Sets with strings" do
      subject.log_hashes_filter = %w[extra_key extra_key password].to_set

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end

    it "accepts Sets with symbols" do
      subject.log_hashes_filter = %i[extra_key extra_key password].to_set

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end

    it "accepts nil" do
      subject.log_hashes_filter = nil

      expect(subject.log_hashes_filter).to match_array %w[password]
    end

    it "accepts empty Array" do
      subject.log_hashes_filter = []

      expect(subject.log_hashes_filter).to match_array %w[password]
    end

    it "accepts empty Set" do
      subject.log_hashes_filter = Set.new

      expect(subject.log_hashes_filter).to match_array %w[password]
    end

    it "accepts Array with nil elements" do
      subject.log_hashes_filter = [nil, "extra_key"]

      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end
  end

  describe ".log_hashes_filter / .log_hashes_filter=" do
    subject { described_class }

    include_examples "log_hashes_filter / log_hashes_filter="
  end

  describe "#log_hashes_filter / #log_hashes_filter=" do
    subject { logger }

    include_examples "log_hashes_filter / log_hashes_filter="

    it "overrides class-level filters" do
      described_class.log_hashes_filter = :foo

      subject.log_hashes_filter = %i[extra_key]

      expect(subject.log_hashes_filter).to_not include "foo"
      expect(subject.log_hashes_filter).to match_array %w[password extra_key]
    end
  end

  shared_examples_for "log_hashes" do
    it "filters out passwords when keys are symbols" do
      hash = {:a => {:b => 1, :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      expect(buffer.string).to include(":password: [FILTERED]")
    end

    it "filters out passwords when keys are strings" do
      hash = {"a" => {"b" => 1, "password" => "pa$$w0rd"}}

      run_log_hashes(hash)

      expect(buffer.string).to include("password: [FILTERED]")
    end

    it "when :filter is a single element" do
      hash = {:a => {:b => 1, :extra_key => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash, :filter => :extra_key)

      message = buffer.string
      expect(message).to include(':extra_key: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when :filter is an Array" do
      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash, :filter => %i[bind_pwd password amazon_secret])

      message = buffer.string
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when :filter is a Set" do
      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash, :filter => %i[bind_pwd password amazon_secret].to_set)

      message = buffer.string
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when .log_hashes_filter is a single element" do
      described_class.log_hashes_filter = :extra_key

      hash = {:a => {:b => 1, :extra_key => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      message = buffer.string
      expect(message).to include(':extra_key: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when .log_hashes_filter is an Array" do
      described_class.log_hashes_filter = %i[bind_pwd password amazon_secret]

      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      message = buffer.string
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when .log_hashes_filter is a Set" do
      described_class.log_hashes_filter = %i[bind_pwd password amazon_secret].to_set

      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      message = buffer.string
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "filters out encrypted values" do
      hash = {:a => {:b => 1, :extra_key => "v2:{c5qTeiuz6JgbBOiDqp3eiQ==}"}}

      run_log_hashes(hash)

      expect(buffer.string).to include(':extra_key: [FILTERED]')
    end

    it "filters out substring matches when keys are strings" do
      hash = {"a" => {"b" => 1, "root_password" => "pa$$w0rd"}}

      run_log_hashes(hash)

      expect(buffer.string).to include("root_password: [FILTERED]")
    end

    it "filters out substring matches when keys are symbols" do
      hash = {:a => {:b => 1, :root_password => "pa$$w0rd"}}

      run_log_hashes(hash)

      expect(buffer.string).to include(":root_password: [FILTERED]")
    end

    it "handles logging hash-like classes" do
      require "active_support"
      require "active_support/core_ext/hash"
      hash = ActiveSupport::HashWithIndifferentAccess.new(:a => 1, :b => {:c => 3})

      run_log_hashes(hash)

      expect(buffer.string).to include(<<~EOS)
        ---
        a: 1
        b:
          c: 3
      EOS
    end
  end

  describe ".log_hashes" do
    def run_log_hashes(hash, options = nil)
      if options
        described_class.log_hashes(logger, hash, options)
      else
        described_class.log_hashes(logger, hash)
      end
    end

    include_examples "log_hashes"
  end

  describe "#log_hashes" do
    def run_log_hashes(hash, options = nil)
      if options
        logger.log_hashes(hash, options)
      else
        logger.log_hashes(hash)
      end
    end

    include_examples "log_hashes"

    it "when #log_hashes_filter is a single element" do
      logger.log_hashes_filter = :extra_key

      hash = {:a => {:b => 1, :extra_key => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      message = buffer.string
      expect(message).to include(':extra_key: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when #log_hashes_filter is an Array" do
      logger.log_hashes_filter = %i[bind_pwd password amazon_secret]

      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      message = buffer.string
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end

    it "when #log_hashes_filter is a Set" do
      logger.log_hashes_filter = %i[bind_pwd password amazon_secret].to_set

      hash = {:a => {:b => 1, :bind_pwd => "pa$$w0rd", :amazon_secret => "pa$$w0rd", :password => "pa$$w0rd"}}

      run_log_hashes(hash)

      message = buffer.string
      expect(message).to include(':bind_pwd: [FILTERED]')
      expect(message).to include(':amazon_secret: [FILTERED]')
      expect(message).to include(':password: [FILTERED]')
    end
  end

  context "long messages" do
    it "truncates long messages when max_message_size is set" do
      msg = "a" * 10.kilobytes
      _, message = logger.formatter.call(:error, Time.now.utc, "", msg).split("-- : ")

      expect(message.strip.size).to eq(8.kilobytes)
    end
  end
end
