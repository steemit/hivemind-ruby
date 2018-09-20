require 'test_helper'

module Hive
  class StateTest < ActiveSupport::TestCase
    def test_state_not_empty
      refute State.none?
    end
    
    def test_state_block_num
      assert State.block_num
    end
    
    def test_state_dgpo
      assert State.dgpo
    end
    
    def test_state_bogus
      assert_raises NoMethodError do
        State.bogus
      end
    end
  end
end
