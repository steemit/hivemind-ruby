module Hive
  
  # Tracks reblogging (re-steems).
  class Reblog < Base
    self.table_name = :hive_reblogs
    self.primary_keys = %i(account post_id)
    
    belongs_to :post
    belongs_to :reblogger, primary_key: :name, foreign_key: :account, class_name: 'Account'
  end
end
