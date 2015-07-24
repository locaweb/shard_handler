require 'spec_helper'

RSpec.describe ShardHandler::Handler do
  let(:configs) do
    {
      'shard1' => { 'adapter' => 'postgresql' },
      'shard2' => { 'adapter' => 'postgresql' }
    }
  end

  subject { described_class.new(ShardHandler::Model, configs) }

  describe '#setup' do
    before { subject.setup }

    it 'creates an instance of connection handler for each shard' do
      expect(subject.connection_handler_for(:shard1))
        .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
      expect(subject.connection_handler_for(:shard2))
        .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
    end

    it 'does not use the same instance for two different shards' do
      expect(subject.connection_handler_for(:shard1))
        .to_not be(subject.connection_handler_for(:shard2))
    end
  end

  describe '#connection_handler_for' do
    before { subject.setup }

    context 'passing a symbol' do
      it 'returns an instance of connection handler' do
        expect(subject.connection_handler_for(:shard1))
          .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
      end
    end

    context 'passing a string' do
      it 'returns an instance of connection handler' do
        expect(subject.connection_handler_for('shard1'))
          .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
      end
    end

    context 'passing nil' do
      it 'returns nil' do
        expect(subject.connection_handler_for(nil)).to be nil
      end
    end

    context 'passing an inexistent shard name' do
      it 'raises an error' do
        expect do
          subject.connection_handler_for(:foobar)
        end.to raise_error(ShardHandler::UnknownShardError,
                           ':foobar is not a valid shard name')
      end
    end
  end

  describe '#disconnect_all' do
    before { subject.setup }

    it 'clear all active connections' do
      expect(subject.connection_handler_for(:shard1))
        .to receive(:clear_all_connections!)
      expect(subject.connection_handler_for(:shard2))
        .to receive(:clear_all_connections!)

      subject.disconnect_all
    end
  end
end
