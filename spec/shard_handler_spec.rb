require 'spec_helper'

RSpec.describe ShardHandler do
  describe '.current_shard and .current_shard= acessors' do
    it 'sets a shard name for the current thread' do
      described_class.current_shard = :shard1
      expect(described_class.current_shard).to be :shard1
    end

    context 'passing nil' do
      it 'sets current shard to nil' do
        described_class.current_shard = nil
        expect(described_class.current_shard).to be nil
      end
    end

    context 'passing a string' do
      it 'casts the value as symbol' do
        described_class.current_shard = 'shard1'
        expect(described_class.current_shard).to be :shard1
      end
    end
  end

  describe '.setup' do
    before do
      described_class.setup({
        "shard1" => { "adapter" => "postgresql",
                      "encoding" => "unicode",
                      "database" => "shard1",
                      "username" => "postgres",
                      "password" => nil },
        "shard2" => { "adapter" => "postgresql",
                      "encoding" => "unicode",
                      "database" => "shard2",
                      "username" => "postgres",
                      "password" => nil }
      })
    end

    it 'initializes connection handlers cache' do
      expect(ShardHandler::Cache.connection_handlers.size).to eql(2)
    end

    it 'creates an instance of connection handler for each shard' do
      expect(ShardHandler::Cache.connection_handlers[:shard1])
        .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
      expect(ShardHandler::Cache.connection_handlers[:shard2])
        .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
    end

    it 'does not set the same instance for two different shards' do
      expect(ShardHandler::Cache.connection_handlers[:shard1])
        .to_not be(ShardHandler::Cache.connection_handlers[:shard2])
    end
  end
end
