module Hive
  
  # Tracks community members.
  class Member < Base
    self.table_name = :hive_members
    self.primary_keys = %i(community account)
    
    has_many :communities, primary_key: :community, foreign_key: :name
    has_many :accounts, primary_key: :account, foreign_key: :name
    has_many :posts, through: :communities
    has_many :post_tags, through: :posts
    
    scope :admin, lambda { |admin = true| where(is_admin: admin) }
    scope :mod, lambda { |mod = true| where(is_mod: mod) }
    scope :approved, lambda { |approved = true| where(is_approved: approved) }
    scope :muted, lambda { |muted = true| where(is_muted: muted) }
  end
end
