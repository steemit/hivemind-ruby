require 'test_helper'

module Hive
  class BlockTest < ActiveSupport::TestCase
    def test_first_block
      assert_equal '0000000000000000000000000000000000000000', Block.first[:hash]
    end
    
    def test_block_with_payments
      assert Block.with_promoted_posts.any?
    end
  end
end
