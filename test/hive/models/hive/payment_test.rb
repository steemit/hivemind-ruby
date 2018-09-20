require 'test_helper'

module Hive
  class PaymentTest < ActiveSupport::TestCase
    def setup
      @null_account = Account.find_by_name 'null'
      @payment = Payment.first
    end
    
    def test_payment_not_empty
      refute Payment.none?
    end
    
    def test_block
      assert @payment.block
    end
    
    def test_post
      assert @payment.post
    end
    
    def test_from
      assert @payment.from
    end
    
    def test_to
      assert @payment.to
    end
    
    def test_only_to_null
      refute Payment.where.not(to_account: @null_account).any?, 'only expect payments to null'
    end
    
    def test_token
      assert Payment.token('SBD').any?
      refute Payment.token('SBD', invert: true).any?, 'only expect payments in SBD'
    end
    
    def test_minimum_amount
      refute Payment.where('amount < 0.001').any?, 'did not expect amount smaller than 0.001'
    end
    
    def test_top_amount
      assert Payment.top_amount(:post, 1)
    end
    
    def test_post_scope
      assert Payment.post(Post.promoted.first).limit(1).any?
      assert Payment.post(Post.promoted.first, invert: true).limit(1).any?
    end
  end
end
