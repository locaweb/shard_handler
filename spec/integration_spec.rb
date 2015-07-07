require 'spec_helper'
require 'support/db'

class Post < ShardHandler::Model
end

describe ShardHandler do
  before(:all) do
    Db.setup_shards
    Db.connect_to_shard('shard1')
    Db.connection.execute <<-SQL
      INSERT INTO posts (title) VALUES ('post from shard1')
    SQL
    Db.connect_to_shard('shard2')
    Db.connection.execute <<-SQL
      INSERT INTO posts (title) VALUES ('post from shard2')
    SQL
    Db.connect_to_root

    described_class.setup(Db.shards_config)
  end

  after(:all) do
    if described_class.cache
      described_class.cache.connection_handler_for('shard1').clear_all_connections!
      described_class.cache.connection_handler_for('shard2').clear_all_connections!
    end
    DbHelper.drop_shards
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
