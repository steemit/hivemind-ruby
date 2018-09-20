require 'test_helper'

module Hive
  class MemberTest < ActiveSupport::TestCase
    def test_member_empty
      assert Member.none?
    end
  end
end
