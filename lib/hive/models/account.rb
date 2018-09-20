module Hive
  
  # To find an {Hive::Account}, use the following idiom:
  # 
  #     alice = Hive::Account.find_by_name 'alice'
  # 
  # An account has many {Hive::Post} records.  To access associated posts, use:
  # 
  #    alice.posts
  # 
  # Like posts, account has many {Hive::PostsCache} records.  There are two ways
  # to access an account's related {Hive::PostsCache} records.
  # 
  #     alice.posts.joins(:cache) # which includes posts_cache fields
  #     alice.posts_cache # automatically joins posts to get posts_cache
  # 
  # An account also has many {Hive::Reblog} records that can be used to access
  # reblogged posts, which are the posts that the account has reblogged
  # (aka re-steemed):
  # 
  #    alice.reblogged_posts
  # 
  # Accounts also have access to {Hive::Follow} for various things like "follow"
  # and "mute".
  # 
  #     alice.following # accounts that this account is following
  #     alice.followers # accounts that follow this account
  #     alice.muting # accounts that this account is muting
  #     alice.muters # accounts that mute this account
  # 
  # Post promotions are tracked by {Hive::Payment} and associated with accounts
  # as well.  To get a list of posts that this account has promoted:
  # 
  #     alice.promoted_posts
  # 
  # Also, you can get a list of all accounts that this account has promoted at
  # some point.
  # 
  #     alice.promoted_authors
  # 
  # This is the sum of all post promotion by this account, grouped by the author
  # being promoted:
  # 
  #     puts JSON.pretty_generate alice.payments.
  #       joins(:post).group(:author).sum(:amount)
  # 
  # This scope will limit the number of accounts to those who have only ever
  # posted *n* times:
  # 
  #     Hive::Account.root_posts_count(1)
  #     Hive::Account.root_posts_count(1..5) # accounts with between 1 and 5 posts
  class Account < Base
    self.table_name = :hive_accounts
    
    has_many :posts, primary_key: :name, foreign_key: :author, inverse_of: :author_account
    has_many :posts_cache, through: :posts, source: :cache
    
    has_many :reblogs, primary_key: :name, foreign_key: :account, inverse_of: :reblogger
    has_many :reblogged_posts, through: :reblogs, source: :post
    has_many :inverse_rebloggers, through: :reblogged_posts, source: :rebloggers
    
    has_many :raw_follows, foreign_key: :follower, class_name: 'Follow'
    has_many :inverse_raw_follows, foreign_key: :following, class_name: 'Follow'
    
    has_many :follows, -> { state(:follow) }, foreign_key: :follower, class_name: 'Follow'
    has_many :following, through: :follows, source: :following_account
    has_many :inverse_follows, -> { state(:follow) }, foreign_key: :following, class_name: 'Follow'
    has_many :followers, through: :inverse_follows, source: :follower_account
    
    has_many :mutes, -> { state(:mute) }, foreign_key: :follower, class_name: 'Follow'
    has_many :muting, through: :mutes, source: :following_account
    has_many :inverse_mutes, -> { state(:mute) }, foreign_key: :following, class_name: 'Follow'
    has_many :muters, through: :inverse_mutes, source: :follower_account
    
    has_many :payments, -> { to_null.token('SBD') }, foreign_key: :from_account, source: :from
    has_many :promoted_posts, through: :payments, source: :post
    has_many :promoted_authors, -> { distinct }, through: :promoted_posts, source: :author_account
    
    has_many :memberships, primary_key: :name, foreign_key: :account, class_name: 'Member'
    
    has_many :feed_cache
    has_many :feed_posts, through: :feed_cache, source: :post
    
    scope :root_posts_count, lambda { |count, options = {invert: false}|
      clause = <<~DONE
        (
          SELECT COUNT(hive_posts.id) FROM hive_posts
          WHERE hive_posts.author = hive_accounts.name
          AND hive_posts.depth = 0
          AND hive_posts.parent_id IS NULL
        ) 
      DONE
      
      clause += 'NOT ' if !!options[:invert]
      
      r = case count
      when Range
        count = [count.first, count.last]
        clause += 'BETWEEN ? AND ?'
        
        where(clause, *count)
      else
        count = [count].flatten
        clause += 'IN (?)'
        
        where(clause, count)
      end
    }
    
    # The entire feed for this account, as in, all content created/reblogged by
    # authors that this account follows.
    # 
    # @return {ActiveRecord::Relation}
    def feed_cache; Post.feed_cache(following); end
    
    # The entire feed for this account, as in, all content created/reblogged by
    # authors that this account follows.
    # 
    # @return {ActiveRecord::Relation}
    def feed; Post.feed(following); end
    
    # The entire ignred feed for this account, as in, all content
    # created/reblogged by authors that this account mutes.
    # 
    # @return {ActiveRecord::Relation}
    def ignored_feed_cache; Post.feed_cache(muting); end
    
    # The entire ignred feed for this account, as in, all content
    # created/reblogged by authors that this account mutes.
    # 
    # @return {ActiveRecord::Relation}
    def ignored_feed; Post.feed(muting); end
    
    # All comments that have replied to this account, as in, all content that
    # has the parent_author as this account.
    def replies; Post.replies(parent_author: self); end
  end
end
