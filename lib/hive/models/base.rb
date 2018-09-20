require 'active_record'
require 'safe_attributes'
require 'composite_primary_keys'

begin
  require 'marginalia'
rescue LoadError
  # skip
end

module Hive
  
  # Abstract calss for all {Hive} active record classes.
  class Base < ActiveRecord::Base
    include SafeAttributes
    
    self.abstract_class = true
    
    database_url = ENV.fetch('DATABASE_URL', 'postgresql://user:pass@localhost:5432/hive')
    database_uri = URI.parse(database_url)
    database = database_uri.path.split('/').last
    
    establish_connection({
      adapter: database_uri.scheme,
      host: ENV.fetch('HIVE_HOST', database_uri.host),
      port: ENV.fetch('HIVE_PORT', database_uri.port),
      username: ENV.fetch('HIVE_USERNAME', database_uri.user),
      password: ENV.fetch('HIVE_PASSWORD', database_uri.password),
      database: ENV.fetch('HIVE_DATABASE', database),
      timeout: 60
    })
    
    scope :invertable, lambda { |expression, args, options = {invert: false}|
      args = [args].flatten
      
      if !!options[:invert]
        where.not(expression, *args)
      else
        where(expression, *args)
      end
    }
    
    # Please note, these are not comprehensive safeguards for marking records
    # read-only.  It's better to completely revoke write access from the user
    # role at the lowest DBMS permission level.
    
    after_initialize :readonly!
    
    # Disabled
    def self.delete(_=nil); raise ActiveRecord::ReadOnlyRecord; end
    
    # Disabled
    def self.delete_all(_=nil); raise ActiveRecord::ReadOnlyRecord; end
    
    # Disabled
    def self.update_all(_=nil); raise ActiveRecord::ReadOnlyRecord; end
    
    # Disabled
    def delete(_=nil); raise ActiveRecord::ReadOnlyRecord; end
    
    # Disabled
    def update(*_); raise ActiveRecord::ReadOnlyRecord; end
    
    # Uses ducktyping to query on account so that you can pass any type and
    # still get a valid match.
    # 
    # So you can do:
    # 
    #     Hive::Post.where(author: 'alice')
    #     Hive::Post.where(author: %w(alice bob))
    #     Hive::Post.where(author: Hive::Account.find_by_name('alice'))
    #     Hive::Post.where(author: Hive::Account.where('name LIKE ?', '%z%'))
    # 
    # @param account {String|<String>|Account|ActiveRecord::Relation} the
    #   account(s) to match on
    def self.transform_account_selector(account)
      case account
      when String then account
      when Array then account
      when Account then account.name
      else
        unless account.is_a? ActiveRecord::Relation
          raise "Don't know what to do with: #{account.class}"
        end
        
        account.select(:name)
      end
    end
  end
end
