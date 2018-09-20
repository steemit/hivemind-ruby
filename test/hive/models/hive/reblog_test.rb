require 'test_helper'

module Hive
  class ReblogTest < ActiveSupport::TestCase
    def test_reblog_not_empty
      refute Reblog.none?
    end
  end
end
