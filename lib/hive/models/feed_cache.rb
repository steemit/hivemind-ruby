module Hive
  
  # Tracks feed cache.
  class FeedCache < Base
    self.table_name = :hive_feed_cache
    self.primary_keys = %i(post_id account_id)
    
    belongs_to :post
    belongs_to :account
    
    scope :posts, lambda { |post| where(post: post) }
    scope :accounts, lambda { |account| where(account: account) }
  end
end
