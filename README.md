[![Gem Version](https://badge.fury.io/rb/hivemind-ruby.svg)](https://badge.fury.io/rb/hivemind-ruby)
[![Inline docs](http://inch-ci.org/github/steemit/hivemind-ruby.svg?branch=master&style=shields)](http://inch-ci.org/github/steemit/hivemind-ruby)

# `hivemind-ruby` - Object Relational Mapping for Hivemind

If you run your own `hivemind` node, you can leverage your local subset of the blockchain you've synchronized to Postgres using ActiveRecord.

What does that mean?  It means if, for example, you have an existing Rails application, you can use this gem to access your `hivemind` node and access all of the data stored there.

Full documentation: http://www.rubydoc.info/gems/hivemind-ruby

## Overview

##### What problem does this tool solve?

It allows you to bypass `steemd` and access a representation of the blockchain maintained by `hivemind` for certain types of queries.

##### Why would I want to bypass `steemd`?  Isn't that the authoritative way to access the blockchain?

Yes, `steemd` is authoritative.  But for certain kinds of queries, there are alternatives.  For example, if you wanted to find all users that have the letter `z` in their account name, `steemd` is not the best tool.

Instead, we can use an SQL statement like:

```sql
SELECT "hive_accounts".*
FROM   "hive_accounts"
WHERE  (name LIKE '%z%');
```

But, you don't have to write this SQL.  You can let ActiveRecord do it instead:

```ruby
Hive::Account.where("name LIKE ?", '%z%')
```

To do this query comprehensively with `steemd` would require hours of API calls to find accounts that match.  But using SQL, it takes less than a second.

##### What can I query with `hivemind`?

The focus of `hivemind` is on communities:

[Developer-friendly microservice powering social networks on the Steem blockchain.
](https://github.com/steemit/hivemind#developer-friendly-microservice-powering-social-networks-on-the-steem-blockchain)

> Hive is a "consensus interpretation" layer for the Steem blockchain, maintaining the state of social features such as post feeds, follows, and communities. Written in Python, it synchronizes an SQL database with chain state, providing developers with a more flexible/extensible alternative to the raw steemd API.

You should refer to the main `hivemind` [purpose](https://github.com/steemit/hivemind#purpose) to determine specifically what blockchain data it will index.

This tool will allow rubyists to access the same database that `hivemind` maintains.

## Getting Started

The hivemind-ruby gem is compatible with Ruby 2.2.5 or later.  Also targets [ActiveRecord 5.2](https://github.com/rails/rails/blob/v5.2.0/activerecord/CHANGELOG.md#rails-520-april-09-2018), but older versions may work as well.

## Installation

*(Assuming that [Ruby is installed](https://www.ruby-lang.org/en/downloads/) on your computer, as well as [RubyGems](http://rubygems.org/pages/download))*

First, you need your own [`hivemind`](https://github.com/steemit/hivemind) node.  A `hivemind` node requires at least 310GB of HDD storage for the database (as of August of 2018).

Once it's running and all synced, just make sure you can access Postgres locally, e.g.:

```bash
psql hive
```

If that works, you can use this gem.  Keep in mind, if you stop the sync, your Postgres database will fall behind the head block.  Once you resume, `hivemind` will pick up where it left off.

*It's that easy!*

Add this line to your application's Gemfile:

```ruby
gem 'hivemind-ruby', require: 'hive'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install hivemind-ruby
```

## Usage

If you've already installed the gem, to check on your configuration, use this command from the terminal:

```bash
export DATABASE_URL=postgresql://user:pass@localhost:5432/hive
hivmind-ruby
```

Or, if you'd like to use the interactive ruby console with `hive` already required:

```bash
hivmind-ruby console
```

Here are a bunch of ActiveRecord queries you can do in your app (or from the interactive console).

This will return the number of accounts currently synced:

```ruby
Hive::Account.count
```

To do the same as accounts, but for posts, this counts everything, including root posts and comments:

```ruby
Hive::Post.count
```

This counts just the number of root posts (not comments):

```ruby
Hive::Post.root_posts.count
```

This counts just the number of comments (not root posts):

```ruby
Hive::Post.replies.count
Hive::Post.replies(parent_author: 'alice').count # just replies to alice
Hive::Post.replies(parent_author: %w(alice bob)).count # just replies to alice or bob
```

This will report the number of accounts with `z` in their name:

```ruby
accounts = Hive::Account.where("name LIKE ?", '%z%')
accounts.count
```

This will show you the number of root posts by `alice`:

```ruby
alice = Hive::Account.find_by_name 'alice'
alice.posts.root_posts.count
```

This will show you the number of reblogs by `alice`:

```ruby
alice = Hive::Account.find_by_name 'alice'
alice.reblogged_posts.count
```

This is the number of accounts that `alice` follows:

```ruby
alice = Hive::Account.find_by_name 'alice'
alice.following.count
```

This is the number of accounts that follow `alice`:

```ruby
alice = Hive::Account.find_by_name 'alice'
alice.followers.count
```

The entire feed for `alice` (all content created by accounts `alice` follows, roughly analogous to https://steemit.com/@alice/feed):

```ruby
alice = Hive::Account.find_by_name 'alice'
alice.feed.count
```

This is the entire discussion for the first post on the Steem platform (e.g.: https://steemit.com/@steemit/firstpost):

```ruby
firstpost = Hive::Post.first
firstpost.discussion.count
```

To get the direct children of a post:

```ruby
firstpost = Hive::Post.first
firstpost.children.count
```

### Tests

* Clone the client repository into a directory of your choice:
  * `git clone https://github.com/steemit/hivemind-ruby.git`
* Navigate into the new folder
  * `cd hivemind-ruby`
* All tests can be invoked as follows:
  * `DATABASE_URL=postgresql://user:pass@localhost:5432/hive bundle exec rake test`

## Contributions

Patches are welcome! Contributors are listed in the `hivemind-ruby.gemspec` file. Please run the tests (`rake test`) before opening a pull request and make sure that you are passing all of them. If you would like to contribute, but don't know what to work on, check the issues list.

## Issues

When you find issues, please report them!

## License

MIT
