require 'spec_helper'
require 'db_helper'

class Post < ShardHandler::Model
end

describe ShardHandler do
  before(:all) do
    DbHelper.setup_shards
    DbHelper.connect_to_shard('shard1')
    DbHelper.connection.execute <<-SQL
      INSERT INTO posts (title) VALUES ('post from shard1')
    SQL
    DbHelper.connect_to_shard('shard2')
    DbHelper.connection.execute <<-SQL
      INSERT INTO posts (title) VALUES ('post from shard2')
    SQL
    DbHelper.connect_to_root

    ShardHandler.setup(DbHelper.shards_config)
  end

  after(:all) do
    if ShardHandler.cache
      ShardHandler.cache.connection_handler_for('shard1').clear_all_connections!
      ShardHandler.cache.connection_handler_for('shard2').clear_all_connections!
    end
    DbHelper.drop_shards
  end

  context 'no shard set' do
    it 'raises an error' do
      expect {
        Post.all.to_a
      }.to raise_error(ActiveRecord::StatementInvalid, /PG::UndefinedTable/)
    end
  end

  context 'shard set' do
    it 'executes the query on the selected shard' do
      ShardHandler.using('shard1') do
        expect(Post.pluck(:title)).to eql(['post from shard1'])
      end

      ShardHandler.using('shard2') do
        expect(Post.pluck(:title)).to eql(['post from shard2'])
      end
    end
  end
end
