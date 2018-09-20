module Hive
  
  # Tracks the payments sent to the `null` account for Post Promotion purposes.
  # 
  # To grab the top 100 most promoted, grouped by post promoted sum:
  # 
  #     Hive::Payment.top_amount(:post, 100)
  #     Hive::Payment.top_amount # same as #top_amount
  class Payment < Base
    self.table_name = :hive_payments
    
    belongs_to :block, foreign_key: :block_num
    belongs_to :post
    belongs_to :from, foreign_key: :from_account, class_name: 'Account'
    belongs_to :to, foreign_key: :to_account, class_name: 'Account'
    
    scope :to_null, -> { where(to_account: Account.where(name: 'null')) }
    
    scope :token, lambda { |token = 'SBD', options = {invert: false}|
      if !!options[:invert]
        where.not(token: token)
      else
        where(token: token)
      end
    }
    
    scope :top_amount, lambda { |what = :post, limit = 100|
      group(what).limit(limit).order('sum_amount desc').sum(:amount)
    }
    
    scope :post, lambda { |post, options = {invert: false}|
      if !!options[:invert]
        where.not(post: post)
      else
        where(post: post)
      end
    }
  end
end
