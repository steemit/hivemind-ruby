module Hive
  
  # Tracks communities.
  class Community < Base
    self.table_name = :hive_communities
    self.primary_key = :name
    
    has_many :posts, primary_key: :name, foreign_key: :community, inverse_of: :community_record
    has_many :post_tags, through: :posts
    has_many :members, primary_key: :name, foreign_key: :community
    has_many :accounts, through: :members
  end
end
