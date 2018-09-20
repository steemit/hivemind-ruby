module Hive
  
  # Tracks post flags.
  class Flag < Base
    self.table_name = :hive_flags
    self.primary_keys = %i(account post_id)
    
    belongs_to :post
    belongs_to :account_record, primary_key: :name, foreign_key: :account, class_name: 'Account'
  end
end
