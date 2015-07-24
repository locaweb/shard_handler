require 'spec_helper'

RSpec.describe ShardHandler::Model do
  it { expect(described_class.abstract_class).to be true }

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
    let(:handler) { double }

    context 'shard set' do
      it 'returns a connection handler for the current thread' do
        allow(ShardHandler).to receive(:current_connection_handler) { handler }
        expect(described_class.connection_handler).to be handler
      end
    end

    context 'no shard set' do
      it 'returns ActiveRecord\'s default connection handler' do
        allow(ShardHandler).to receive(:current_connection_handler) { nil }
        expect(described_class.connection_handler)
          .to be(ActiveRecord::Base.default_connection_handler)
      end
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
