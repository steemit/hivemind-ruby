require 'test_helper'

module Hive
  class PostsCacheTest < ActiveSupport::TestCase
    def test_posts_cache_empty
      refute PostsCache.none?
    end
    
    def test_top_payout
      assert PostsCache.top_payout(:category, 1)
    end
    
    def test_after
      refute PostsCache.after(1.day.from_now).any?
    end
    
    def test_before
      refute PostsCache.before(99.years.ago).any?
    end
    
    def test_updated_after
      refute PostsCache.updated_after(1.day.from_now).any?
    end
    
    def test_updated_before
      refute PostsCache.updated_before(99.years.ago).any?
    end
  end
end
