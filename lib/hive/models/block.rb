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
  #
  # To find blocks that have normal intervals:
  # 
  #     blocks = Hive::Block.block_interval(is: 3.seconds)
  # 
  # To find blocks that have longer than normal intervals:
  # 
  #     blocks = Hive::Block.block_interval(min: 4.seconds)
  # 
  # To find blocks that have shorter than normal intervals:
  # 
  #     blocks = Hive::Block.block_interval(max: 2.seconds)
  # 
  # To find blocks that have intervals in a certain range:
  # 
  #     blocks = Hive::Block.block_interval(min: 15.seconds, max: 30.seconds)
  # 
  # Full report of slow blocks on the entire chain, grouped by date, sorted by
  # the total slow blocks for that day:
  # 
  #     puts JSON.pretty_generate Hive::Block.block_interval(min: 4.seconds).
  #       group('CAST(hive_blocks.created_at AS DATE)').order("count_all").count
  # 
  # Same report as above, grouped by month, sorted by the total slow blocks for
  # that month:
  # 
  #     puts JSON.pretty_generate Hive::Block.block_interval(min: 4.seconds).
  #       group("TO_CHAR(hive_blocks.created_at, 'YYYY-MM')").order("count_all").count
  # 
  # Same report as above, sorted by month:
  # 
  #     puts JSON.pretty_generate Hive::Block.block_interval(min: 4.seconds).
  #       group("TO_CHAR(hive_blocks.created_at, 'YYYY-MM')").
  #       order("to_char_hive_blocks_created_at_yyyy_mm").count
  # 
  class Block < Base
    self.table_name = :hive_blocks
    self.primary_key = :num
    
    belongs_to :previous, primary_key: :hash, foreign_key: :prev, class_name: 'Block'
    belongs_to :next, primary_key: :prev, foreign_key: :hash, class_name: 'Block'
    has_many :payments, foreign_key: :block_num
    has_many :promoted_posts, through: :payments, source: :post
    has_many :post_promoters, through: :payments, source: :from
    
    scope :with_promoted_posts, -> { where num: Payment.select(:block_num) }
    scope :decorate_block_interval, lambda { |units = :seconds|
      columns = [arel_table[Arel.star]]
      columns << "#{block_interval_column(units)} AS block_interval"
      
      joins(:previous).select(columns)
    }
    scope :block_interval, lambda { |options = {is: 3.seconds}|
      is = options[:is]
      min = options[:min] || is
      max = options[:max] || is
      r = joins(:previous)
      
      if !!min && !!max
        if min == max
          r = r.where("#{block_interval_column} = ?", min)
        else
          r = r.where("#{block_interval_column} BETWEEN ? AND ?", min, max)
        end
      else
        r = r.where("#{block_interval_column} <= ?", max) if !!max
        r = r.where("#{block_interval_column} >= ?", min) if !!min
      end
      
      r
    }
  private
    def self.block_interval_column(units = :seconds)
      "EXTRACT(#{units} FROM hive_blocks.created_at - previous_hive_blocks.created_at)"
    end
  end
end
