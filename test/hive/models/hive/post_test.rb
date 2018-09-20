require 'test_helper'

module Hive
  class PostTest < ActiveSupport::TestCase
    def setup
      @firstpost = Post.first
    end
    
    def test_parent
      assert_nil @firstpost.parent, 'expect firstpost parent: nil'
    end
    
    def test_children
      refute @firstpost.children.none?, 'did not expect zero children'
    end
    
    def test_author_account
      assert_equal 'steemit', @firstpost.author_account.name
    end
    
    def test_followers
      refute @firstpost.followers.none?, 'did not expect zero followers'
    end
    
    def test_community_record
      assert_nil @firstpost.community_record, 'expect community record: nil'
    end
    
    def test_flags
      assert @firstpost.flags.none?, 'expect zero flags'
    end
    
    def test_flaggers
      assert @firstpost.flaggers.none?, 'expect zero flaggers'
    end
    
    def test_reblogs
      refute @firstpost.reblogs.none?, 'did not expect zero reblogs'
    end
    
    def test_rebloggers
      refute @firstpost.rebloggers.none?, 'did not expect zero rebloggers'
    end
    
    def test_post_tags
      refute @firstpost.post_tags.none?, 'did not expect zero post tags'
    end
    
    def test_payments
      assert @firstpost.payments.none?, 'expect zero payments'
    end
    
    def test_promoters
      assert @firstpost.promoters.none?, 'expect zero promoters'
    end
    
    def test_tags
      refute @firstpost.tags.none?, 'did not expect zero tags'
    end
    
    def test_author_ned
      assert Post.author('ned').any?
    end
    
    def test_community_ned
      assert Post.community('ned').any?
    end
    
    def test_category_ned
      assert Post.category('category').any?
    end
    
    def test_depth
      posts = Post.depth(0).limit(1000)
      assert posts.any?
      assert_equal posts.count, posts.root_posts.count
      refute_equal posts.count, Post.replies.count
    end
    
    def test_replies_to_author
      post = Post.where(author: 'ned').first
      account = post.author_account
      assert Post.replies(parent_author: account).any?
      assert Post.replies(parent_author: account, parent_permlink: post.permlink).any?
    end
    
    def test_deleted
      posts = Post.depth(0)
      assert posts.deleted.any?
      assert posts.deleted(false).any?
    end
    
    def test_pinned
      posts = Post.depth(0)
      refute posts.pinned.any?, 'did not expect pinned posts (yet)'
    end
    
    def test_muted
      refute Post.muted.any?, 'did not expect muted posts (yet)'
    end
    
    def test_valid
      assert Post.valid.any?
    end
    
    def test_promoted
      assert Post.promoted.any?
      assert Post.promoted(false).any?
    end
    
    def test_after
      refute Post.after(1.day.from_now).any?
    end
    
    def test_before
      refute Post.before(99.years.ago).any?
    end
    
    def test_updated_after
      refute Post.updated_after(1.day.from_now).any?
    end
    
    def test_updated_before
      refute Post.updated_before(99.years.ago).any?
    end
    
    def test_reblogged
      posts = Post.limit(1000)
      assert posts.reblogged.any?
      assert posts.reblogged(false).any?
    end
    
    def test_reblogged_by_nobody
      refute Post.rebloggers.any?, 'did not expect reblogged by nobody'
    end
    
    def test_reblogged_by_ned
      assert Post.rebloggers('ned').any?
    end
    
    def test_discussion_fast
      assert Post.last.discussion
    end
    
    def test_discussion_semifast
      parent = Post.replies.last.parent
      assert parent.discussion.any?
    end
    
    def test_feed_cache_with_string
      account = Account.last
      refute Post.feed_cache(account.name).any?, "did not expect feed cache with this string: #{account.name}"
    end
    
    def test_feed_cache_with_string_array
      account = Account.limit(200)
      names = account.pluck(:name)
      assert Post.feed_cache(names).any?, "did not expect feed cache with this string: #{names}"
    end
    
    def test_feed_cache_with_string_invert
      account = Account.last
      assert Post.feed_cache(account.name, invert: true).any?, "expect inverted feed cache with this string: #{account.name}"
    end
    
    def test_feed_cache_with_record
      account = Account.last
      refute Post.feed_cache(account).any?, "did not expect feed cache with this record: #{account.name}"
    end
    
    def test_feed_cache_with_relation
      accounts = Account.limit(200)
      assert Post.feed_cache(accounts).any?, "did not expect feed cache with this relation: #{accounts.pluck(:name)}"
    end
    
    def test_feed_cache_invalid
      assert_raises RuntimeError do
        Post.feed_cache(nil)
      end
    end
    
    def test_feed_with_string
      account = Account.last
      refute Post.feed(account.name).any?, "did not expect feed with this string: #{account.name}"
    end
    
    def test_feed_with_string_array
      account = Account.last(2)
      names = account.pluck(:name)
      refute Post.feed(names).any?, "did not expect feed with this string: #{names}"
    end
    
    def test_feed_with_string_invert
      account = Account.last
      assert Post.feed(account.name, invert: true).any?, "expect inverted feed with this string: #{account.name}"
    end
    
    def test_feed_with_record
      account = Account.last
      refute Post.feed(account).any?, "did not expect feed with this record: #{account.name}"
    end
    
    def test_feed_invalid
      assert_raises RuntimeError do
        Post.feed(nil)
      end
    end
    
    def test_tagged
      assert Post.tagged(%i(steem steemit)).any?
    end
    
    def test_tagged_all
      assert Post.tagged(all: %i(steem steemit)).any?
    end
    
    def test_tagged_any
      assert Post.tagged(any: %i(steem steemit)).any?
    end
    
    def test_tagged_invert
      assert Post.tagged(all: %i(steem steemit), invert: true).any?
    end
    
    def test_mentioned_all
      assert Post.mentioned(all: %i(alice bob)).any?
    end
    
    def test_mentioned_all_invert
      assert Post.mentioned(all: %i(alice bob), invert: true).any?
    end
    
    def test_mentioned_any
      assert Post.mentioned(any: %i(alice bob)).any?
    end
    
    def test_payout_after
      assert Post.payout_after(1.day.ago).any?
    end
    
    def test_payout_after_invert
      assert Post.payout_after(1.day.ago, invert: true).any?
    end
    
    def test_payout_before
      assert Post.payout_before(1.day.ago).any?
    end
    
    def test_payout_before_invert
      assert Post.payout_before(1.day.ago, invert: true).any?
    end
    
    
    def test_payout_zero
      assert Post.payout_zero.any?
    end
    
    def test_payout_zero_false
      assert Post.payout_zero(invert: false).any?
    end
    
    def test_post_app
      assert Post.app('steemit').any?
    end
    
    def test_post_app_invert
      assert Post.app('steemit', invert: true).any?
    end
    
    def test_post_format
      assert Post.format('markdown').any?
    end
    
    def test_post_format_invert
      assert Post.format('markdown', invert: true).any?
    end
    
    def test_order_by_cache_empty
      assert_raises RuntimeError do
        Post.order_by_cache
      end
    end
    
    def test_order_by_created_at
      assert Post.order_by_cache(created_at: :desc).any?
    end
    
    def test_order_by_feed_cache_empty
      assert_raises RuntimeError do
        Post.order_by_feed_cache
      end
    end
    
    def test_order_by_feed_cache_created_at
      assert Post.order_by_feed_cache(created_at: :desc).any?
    end
    
    def test_slug
      assert_equal '@steemit/firstpost', @firstpost.slug
    end
    
    def test_find_by_slug
      slug = '@steemit/firstpost'
      assert_equal slug, Post.find_by_slug(slug).slug
    end
  end
end
