# ShardHandler

This gem is a simple sharding solution for Rails applications. It was created
to be used in multitenant applications, when data is shared across multiple
databases but accessed through the same ActiveRecord model.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shard_handler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shard_handler

## Usage

All models that need sharding must inherit from `ShardHandler::Model`. For
example:

    class Post < ShardHandler::Model
    end

Before executing any query, you must switch to the appropriate shard:

    ShardHandler.current_shard = :shard1
    puts Post.pluck(:title)

    # or

    ShardHandler.using(:shard1) do
      puts Post.pluck(:title)
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/shard_handler.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

