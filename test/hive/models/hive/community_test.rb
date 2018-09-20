require 'test_helper'

module Hive
  class CommunityTest < ActiveSupport::TestCase
    def test_community_empty
      assert Community.none?
    end
  end
end
