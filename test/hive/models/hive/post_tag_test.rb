require 'test_helper'

module Hive
  class PostTagTest < ActiveSupport::TestCase
    def test_post_tag_empty
      refute PostTag.none?
    end
    
    def test_top_count
      assert PostTag.top_count(:tag, 1)
    end
  end
end
