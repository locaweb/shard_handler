require 'spec_helper'
require 'support/db'

class Post < ShardHandler::Model
end

describe ShardHandler do
  before(:all) do
    Db.setup

    Db.connect_to_shard('shard1')
    silence_stream(STDOUT) do
      load('spec/support/shard_schema.rb')
    end
    Db.connection.execute <<-SQL
      INSERT INTO posts (title) VALUES ('post from shard1')
    SQL

    Db.connect_to_shard('shard2')
    silence_stream(STDOUT) do
      load('spec/support/shard_schema.rb')
    end
    Db.connection.execute <<-SQL
      INSERT INTO posts (title) VALUES ('post from shard2')
    SQL

    Db.connect_to_root
  end

  after(:all) do
    Db.teardown
  end

  before do
    described_class.setup(Db.shards_config)
  end

  after do
    if described_class.cache
      described_class.cache.connection_handler_for('shard1').clear_all_connections!
      described_class.cache.connection_handler_for('shard2').clear_all_connections!
    end
  end

  context 'no shard set' do
    it 'raises an error' do
      expect do
        Post.all.to_a
      end.to raise_error(ActiveRecord::StatementInvalid, /PG::UndefinedTable/)
    end
  end

  context 'shard set' do
    it 'executes the query on the selected shard' do
      described_class.using('shard1') do
        expect(Post.pluck(:title)).to eql(['post from shard1'])
      end

      described_class.using('shard2') do
        expect(Post.pluck(:title)).to eql(['post from shard2'])
      end
    end
  end
end
