module Hive
  
  # Tracks post tags.
  # 
  # To grab the top 100 tags, grouped by post count:
  # 
  #     Hive::PostTag.top_count(:tag, 100)
  #     Hive::PostTag.top_count # same as #top_count
  class PostTag < Base
    self.table_name = :hive_post_tags
    self.primary_keys = %i(post_id tag)
    
    belongs_to :post
    
    scope :top_count, lambda { |what = :tag, limit = 100|
      group(what).limit(limit).order('count_all desc').count
    }
  end
end
