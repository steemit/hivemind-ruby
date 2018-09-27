require 'test_helper'

module Hive
  class BlockTest < ActiveSupport::TestCase
    def test_first_block
      assert_equal '0000000000000000000000000000000000000000', Block.first[:hash]
    end
    
    def test_block_with_payments
      assert Block.with_promoted_posts.any?
    end
    
    def test_decorate_block_interval
      assert Block.decorate_block_interval.any?
    end
    
    def test_block_interval
      assert Block.block_interval(is: 3.seconds).any?
    end
    
    def test_block_interval_min
      assert Block.block_interval(min: 3.seconds).any?
    end
    
    def test_block_interval_max
      assert Block.block_interval(max: 3.seconds).any?
    end
    
    def test_block_interval_min_max
      assert Block.block_interval(min: 3.seconds, max: 4.seconds).any?
    end
  end
end
