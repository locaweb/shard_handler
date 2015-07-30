# ShardHandler

[![Build Status][travis-badge]][travis-build]
[![Code Climate][cc-badge]][cc-details]
[![Test Coverage][cc-cov-badge]][cc-cov-details]

This gem is a simple sharding solution for Rails applications. It was created
to be used in multitenant applications, where data is partitioned across
multiple databases but accessed through the same ActiveRecord model. Basically,
this gem is a nice connection switcher for ActiveRecord.

Keep in mind that this gem is tested only with PostgreSQL databases.

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

First, create an abstract model that will handle the shard connection:

```ruby
class Shard < ShardHandler::Model
  self.abstract_class = true
end
```

Create a YAML file like this one:

```yaml
# config/shards.yml
development:
  shard1:
    adapter: postgresql
    database: shard_db_1
    username: postgres
  shard2:
    adapter: postgresql
    database: shard_db_2
    username: postgres
test:
  # ...
production:
  # ...
```

And configure your abstract model:

```ruby
# config/initializers/shard_handler.rb
Shard.setup(Rails.application.config_for(:shards))
```

Any model that has data shared across shards must inherit from your abstract
model:

```ruby
class Message < Shard
end

class Contact < Shard
end
```

To execute a query in a shard, you can use the `.using` method passing the
appropriate shard name:

```ruby
user = User.first

Shard.using(:shard1) do
  puts user.messages.pluck(:title)
  puts user.contacts.pluck(:email)
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

## Debugging PostgreSQL

To see what is going on in a PostgreSQL database, you can enable a more verbose
log for the database:

```txt
# %d = database name
# %l = session line number
# %x = transaction ID (0 if none)
log_line_prefix = '%d %l %x - '
log_statement = 'all'
```

After restarting your database, the log will be like this:

```txt
my_db 1 0 - LOG:  statement: SELECT foo FROM bar
```

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
