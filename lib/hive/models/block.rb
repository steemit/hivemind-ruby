module Hive
  
  # Tracks blocks.
  # 
  # To find blocks that have promoted posts:
  # 
  #     blocks = Hive::Block.with_promoted_posts
  # 
  # With this result, we can get a list of post promoters in that block:
  # 
  #     accounts = blocks.first.post_promoters
  class Block < Base
    self.table_name = :hive_blocks
    self.primary_key = :num
    
    has_many :payments, foreign_key: :block_num
    has_many :promoted_posts, through: :payments, source: :post
    has_many :post_promoters, through: :payments, source: :from
    
    scope :with_promoted_posts, -> { where num: Payment.select(:block_num) }
  end
end
