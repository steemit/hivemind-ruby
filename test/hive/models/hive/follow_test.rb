require 'test_helper'

module Hive
  class FollowTest < ActiveSupport::TestCase
    def test_flag_not_empty
      refute Follow.none?
    end
    
    def test_flag_states
      assert Follow.state(:reset).any?
      assert Follow.state(:follow).any?
      assert Follow.state(:mute).any?
      assert Follow.state(:mute, invert: true).any?
    end
    
    def test_flag_status_wrong
      refute Follow.state(:WRONG).any?
    end
  end
end
