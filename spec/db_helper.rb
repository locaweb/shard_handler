class DbHelper
  class << self
    def db_config
      @db_config ||= YAML.load_file('spec/database.yml')['test']
    end

    def shards_config
      @shards_config ||= YAML.load_file('spec/shards.yml')['test']
    end

    def connection
      ActiveRecord::Base.connection
    end

    # Connects to the master database. This database must be used to perform
    # root actions on PostgreSQL.
    def connect_to_root
      ActiveRecord::Base.establish_connection(
        db_config.merge('database' => 'postgres'))
    end

    # Connects to a shard database. This connection can be used later via
    # ActiveRecord::Base.connection
    def connect_to_shard(name)
      ActiveRecord::Base.establish_connection(shards_config[name])
    end

    # Creates two shards databases and its tables. Must be executed on a clean
    # environment.
    def setup_shards
      connect_to_root

      shards_config.each do |shard, config|
        connection.create_database(config['database'], config)
        ActiveRecord::Base.establish_connection(config)
        execute_migrations
      end
    end

    def drop_shards
      connect_to_root

      shards_config.each do |shard, config|
        connection.drop_database(config['database'])
      end
    end

    private

    def execute_migrations
      ActiveRecord::Schema.define(:version => 20140407140000) do
        create_table "posts", :force => true do |t|
          t.text "title"
          t.text "body"
        end
      end
    end
  end
end
