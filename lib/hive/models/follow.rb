module Hive
  
  # Tracks follows, mutes, and follow/mute resets.
  class Follow < Base
    self.table_name = :hive_follows
    self.primary_keys = %i(follower following)
    
    belongs_to :follower_account, foreign_key: :follower, class_name: 'Account'
    belongs_to :following_account, foreign_key: :following, class_name: 'Account'
    
    scope :state, lambda { |state_name, options = {invert: false}|
      state = case state_name
      when :reset then 0
      when :follow then 1
      when :mute then 2
      else; -1
      end
      
      if !!options[:invert]
        where.not(state: state)
      else
        where(state: state)
      end
    }
  end
end
