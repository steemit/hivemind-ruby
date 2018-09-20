require 'test_helper'

module Hive
  class AccountTest < ActiveSupport::TestCase
    def setup
      @ned = Account.find_by_name 'ned'
    end
    
    def test_posts
      refute @ned.posts.root_posts.none?, 'did not expect zero posts'
    end
    
    def test_posts_joins_cache
      refute @ned.posts.joins(:cache).root_posts.none?, 'did not expect zero posts'
    end
    
    def test_posts_cache
      refute @ned.posts_cache.none?, 'did not expect zero posts'
    end
    
    def test_replies
      refute @ned.posts.replies.none?, 'did not expect zero replies'
    end
    
    def test_reblogs
      refute @ned.reblogs.none?, 'did not expect zero reblogs'
    end
    
    def test_reblogged_posts
      refute @ned.reblogged_posts.none?, 'did not expect zero reblogged posts'
    end
    
    def test_inverse_rebloggers
      refute @ned.inverse_rebloggers.none?, 'did not expect zero inverse rebloggers'
    end
    
    def test_follows
      refute @ned.follows.none?, 'did not expect zero follows'
    end
    
    def test_following
      refute @ned.following.none?, 'did not expect zero following'
    end
    
    def test_inverse_follows
      refute @ned.inverse_follows.none?, 'did not expect zero inverse follows'
    end
    
    def test_followers
      refute @ned.followers.none?, 'did not expect zero followers'
    end
    
    def test_feed
      account = Account.last
      count = account.feed.count
      assert_equal 0, count, "expect zero feed for latest account, got #{count} for #{account.name}"
    end
    
    def test_igored_feed
      assert Account.last.ignored_feed.none?, 'expect zero ignored feed for latest account'
    end
    
    def test_root_posts_count
      assert Account.root_posts_count(0).any?
    end
    
    def test_root_posts_count_invert
      assert Account.root_posts_count(0, invert: true).any?
    end
    
    def test_root_posts_count_array
      assert Account.root_posts_count([0,1]).any?
    end
    
    def test_root_posts_count_range
      assert Account.root_posts_count(0..1).any?
    end
  end
end
