require 'test_helper'

module Hive
  class FlagTest < ActiveSupport::TestCase
    def test_flag_empty
      assert Flag.none?
    end
  end
end
