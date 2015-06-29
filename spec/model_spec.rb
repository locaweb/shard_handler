require 'spec_helper'

RSpec.describe ShardHandler::Model do
  it { expect(described_class.abstract_class).to be true }

  describe '.connection_handler' do
    context 'no shard set' do
      it 'returns the default connection handler' do
        expect(described_class.connection_handler)
          .to be(ActiveRecord::Base.default_connection_handler)
      end
    end

    context 'shard set' do
      let(:shard1) { instance_double(ActiveRecord::ConnectionAdapters::ConnectionHandler) }
      let(:shard2) { instance_double(ActiveRecord::ConnectionAdapters::ConnectionHandler) }

      before do
        ShardHandler::Cache.connection_handlers = { shard1: shard1,
                                                    shard2: shard2 }
      end

      it 'returns a connection handler for the shard' do
        Thread.current[:current_shard_name] = :shard1
        expect(described_class.connection_handler).to be shard1
      end
    end

    context 'invalid shard set' do
      it 'raises an error' do
        Thread.current[:current_shard_name] = :invalid_shard
        expect {
          described_class.connection_handler
        }.to raise_error(ShardHandler::InvalidShardName)
      end
    end
  end

  describe '.establish_connection' do
    it 'raises an error' do
      expect {
        described_class.establish_connection
      }.to raise_error(NoMethodError)
    end
  end
end
