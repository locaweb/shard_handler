require 'spec_helper'

RSpec.describe ShardHandler::Model do
  it { expect(described_class.abstract_class).to be true }

  describe '.setup' do
    it 'initializes connection handlers cache' do
      config = instance_double(Hash)
      handler = instance_double(ShardHandler::Handler)

      expect(ShardHandler::Handler)
        .to receive(:new).with(ShardHandler::Model, config) { handler }
      expect(handler).to receive(:setup)

      described_class.setup(config)
    end
  end

  describe '.current_shard and .current_shard= accessors' do
    it 'sets the shard name for the current thread' do
      described_class.current_shard = :shard1
      expect(described_class.current_shard).to be :shard1
    end

    context 'passing nil' do
      it 'sets the current shard name to nil' do
        described_class.current_shard = nil
        expect(described_class.current_shard).to be nil
      end
    end

    context 'passing a string' do
      it 'casts the value to symbol' do
        described_class.current_shard = 'shard1'
        expect(described_class.current_shard).to be :shard1
      end
    end
  end

  describe '.connection_handler' do
    before do
      described_class.setup('shard1' => { 'adapter' => 'postgresql' })
    end

    context 'current shard is nil' do
      it 'returns the default connection handler' do
        expect_any_instance_of(ShardHandler::Handler)
          .to receive(:connection_handler_for).with(nil) { nil }

        expect(described_class.connection_handler)
          .to be(ActiveRecord::Base.default_connection_handler)
      end
    end

    context 'current_shard is present' do
      it 'returns a connection handler for the current thread' do
        conn_handler = double
        expect_any_instance_of(ShardHandler::Handler)
          .to receive(:connection_handler_for).with(:shard1) { conn_handler }

        described_class.current_shard = :shard1
        expect(described_class.connection_handler).to be conn_handler
      end
    end
  end

  describe '.using' do
    it 'yields a block' do
      expect do |b|
        described_class.using(:shard1, &b)
      end.to yield_with_no_args
    end

    it 'changes the current shard name when executing the block' do
      expect(described_class.current_shard).to be nil

      described_class.using(:shard1) do
        expect(described_class.current_shard).to be :shard1
      end
    end

    it 'changes current shard name back to its value before block execution' do
      described_class.current_shard = :shard2

      described_class.using(:shard1) do
        expect(described_class.current_shard).to be :shard1
      end

      expect(described_class.current_shard).to be :shard2
    end
  end

  describe '.establish_connection' do
    it 'raises an error' do
      expect do
        described_class.establish_connection
      end.to raise_error(NoMethodError)
    end
  end
end
