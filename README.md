# ShardHandler

[![Build Status][travis-badge]][travis-build]
[![Code Climate][cc-badge]][cc-details]
[![Test Coverage][cc-cov-badge]][cc-cov-details]

This gem is a simple sharding solution for Rails applications. It was created
to be used in multitenant applications, when data is shared across multiple
databases but accessed through the same ActiveRecord model.

The documentation is [available on RubyDoc.info][docs].

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

```ruby
class Post < ShardHandler::Model
end
```

Before executing any query, you must switch to the appropriate shard:

```ruby
ShardHandler.current_shard = :shard1
puts Post.pluck(:title)

# or

ShardHandler.using(:shard1) do
  puts Post.pluck(:title)
end
```

## Development

After checking out the repo:

1. Install dependencies using `bin/setup`.
2. Create these 2 files: `spec/database.yml` and `spec/shards.yml` and configure
them with your PostgreSQL database. There are examples at
`spec/database.yml.example` and `spec/shards.yml.example`. **Important:**
these databases *will be destroyed and recreated* on test execution.
3. Run specs using `bundle exec rake spec` to make sure that everything is fine.

You can use `bin/console` to get an interactive prompt that will allow you to
experiment.

## Releasing a new version

If you are the maintainer of this project:

1. Update the version number in `lib/shard_handler/version.rb`.
2. Make sure that all tests are green (run `bundle exec rake spec`).
3. Execute `bundle exec rake release` to create a git tag for the version, push
git commits and tags, and publish the gem on [RubyGems.org][rubygems].

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/locaweb/shard_handler.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

[travis-badge]: https://travis-ci.org/locaweb/shard_handler.svg?branch=master
[travis-build]: https://travis-ci.org/locaweb/shard_handler
[cc-badge]: https://codeclimate.com/github/locaweb/shard_handler/badges/gpa.svg
[cc-details]: https://codeclimate.com/github/locaweb/shard_handler
[cc-cov-badge]: https://codeclimate.com/github/locaweb/shard_handler/badges/coverage.svg
[cc-cov-details]: https://codeclimate.com/github/locaweb/shard_handler/coverage
[docs]: http://www.rubydoc.info/gems/shard_handler
[rubygems]: https://rubygems.org/gems/shard_handler
