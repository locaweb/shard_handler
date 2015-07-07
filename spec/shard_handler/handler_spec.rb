require 'spec_helper'

RSpec.describe ShardHandler::Handler do
  let(:configs) do
    {
      'shard1' => {
        'adapter' => 'postgresql',
        'encoding' => 'unicode',
        'database' => 'shard1',
        'username' => 'postgres',
        'password' => nil
      },
      'shard2' => {
        'adapter' => 'postgresql',
        'encoding' => 'unicode',
        'database' => 'shard2',
        'username' => 'postgres',
        'password' => nil
      }
    }
  end

  subject { described_class.new(configs) }

  describe '#cache_connection_handlers' do
    before do
      subject.cache_connection_handlers
    end

    it 'creates an instance of connection handler for each shard' do
      expect(subject.connection_handler_for(:shard1))
        .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
      expect(subject.connection_handler_for(:shard2))
        .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
    end

    it 'does not set the same instance for two different shards' do
      expect(subject.connection_handler_for(:shard1))
        .to_not be(subject.connection_handler_for(:shard2))
    end
  end

  describe '#connection_handler_for' do
    before do
      subject.cache_connection_handlers
    end

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
  end

  describe '#disconnect_all' do
    before do
      subject.cache_connection_handlers
    end

    it 'clear all active connections' do
      expect(subject.cache.fetch(:shard1)).to receive(:clear_all_connections!)
      expect(subject.cache.fetch(:shard2)).to receive(:clear_all_connections!)

      subject.disconnect_all
    end
  end
end
