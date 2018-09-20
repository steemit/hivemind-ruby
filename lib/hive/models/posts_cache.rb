module Hive
  
  # Tracks posts cache.
  # 
  # To grab the top 100 category, grouped by payout sum:
  # 
  #     Hive::PostsCache.top_payout(:category, 100)
  #     Hive::PostsCache.top_payout # same as #top_payout
  class PostsCache < Base
    self.table_name = :hive_posts_cache
    
    belongs_to :post
    
    scope :posts, lambda { |post| where(post: post) }
    
    scope :paidout, lambda { |paidout = true| where(is_paidout: paidout) }
    scope :nsfw, lambda { |nsfw = true| where(is_nsfw: nsfw) }
    scope :declined, lambda { |declined = true| where(is_declined: declined) }
    scope :full_power, lambda { |full_power = true| where(is_full_power: full_power) }
    scope :hidden, lambda { |hidden = true| where(is_hidden: hidden) }
    scope :grayed, lambda { |grayed = true| where(is_grayed: grayed) }
    
    scope :after, lambda { |after, options = {invert: false}|
      invertable 'hive_posts_cache.created_at > ?', after, options
    }
    
    scope :before, lambda { |before, options = {invert: false}|
      invertable 'hive_posts_cache.created_at < ?', before, options
    }
    
    scope :updated_after, lambda { |after, options = {invert: false}|
      invertable 'hive_posts_cache.updated_at > ?', after, options
    }
    
    scope :updated_before, lambda { |before, options = {invert: false}|
      invertable 'hive_posts_cache.updated_at < ?', before, options
    }
    
    scope :payout_after, lambda { |payout, options = {invert: false}|
      invertable 'hive_posts_cache.payout_at > ?', payout, options
    }
    
    scope :payout_before, lambda { |payout, options = {invert: false}|
      invertable 'hive_posts_cache.payout_at < ?', payout, options
    }
    
    scope :payout_zero, lambda { |payout_zero = false|
      expression = 'hive_posts_cache.payout = 0.0'
      
      if payout_zero
        where(expression)
      else
        where.not(expression)
      end
    }
    
    scope :top_payout, lambda { |what = :category, limit = 100|
      payout_zero(false).declined(false).group(what).limit(limit).
        order('sum_payout DESC').sum(:payout)
    }
    
    scope :app, lambda { |app, options = {version: nil, invert: false}|
      if !!options[:invert]
        where("json::json->>'app' NOT LIKE ?", "#{app}/#{options[:version]}%")
      else
        where("json::json->>'app' LIKE ?", "#{app}/#{options[:version]}%")
      end
    }
    
    scope :format, lambda { |format, options = {invert: false}|
      if !!options[:invert]
        where("json::json->>'format' NOT IN(?)", format)
      else
        where("json::json->>'format' IN(?)", format)
      end
    }
    
    scope :mentioned, lambda { |options = {}|
      relation = all
      
      if !!options[:all]
        names = [options[:all]].flatten
        relation = relation.where('char_length(hive_posts_cache.body) >= ?', names.map(&:size).sum + names.size)
        
        names.each do |name|
          relation = relation.where('hive_posts_cache.body LIKE ?', "%@#{name}%")
        end
      end
      
      if !!options[:any]
        names = [options[:any]].flatten
        relation = relation.where('char_length(hive_posts_cache.body) >= ?', names.map(&:size).max + 1)
        
        clause = names.map do |name|
          'hive_posts_cache.body LIKE ?'
        end.join(' OR ')
        
        relation = relation.where(clause, *options[:any].map{|n| "%@#{n}%"})
      end
      
      if !!options[:invert]
        relation = where.not(post_id: relation.select(:post_id))
      else
        relation
      end
      
      relation
    }
  end
end
