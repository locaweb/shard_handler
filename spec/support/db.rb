class Db
  class << self
    def config
      @config ||= YAML.load_file('spec/database.yml')['test']
    end

    def shards_config
      @shards_config ||= YAML.load_file('spec/shards.yml')['test']
    end

    def connection
      ActiveRecord::Base.connection
    end

    def connect_to_root
      ActiveRecord::Base.establish_connection(
        config.merge('database' => 'postgres'))
    end

    def connect_to_shard(name)
      ActiveRecord::Base.establish_connection(shards_config[name])
    end

    def setup
      shards_config.each do |shard, config|
        connect_to_root
        connection.create_database(config.fetch('database'), config)
        connect_to_shard(shard)
      end
    end

    def teardown
      shards_config.each do |_shard, config|
        connect_to_root
        connection.drop_database(config.fetch('database'))
      end
    end
  end
end
