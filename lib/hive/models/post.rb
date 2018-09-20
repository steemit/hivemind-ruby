module Hive
  
  # Tracks all content including posts, comments (replies).
  # 
  # To find a post, you can do a lookup using the {Hive::Post#find_by_slug} scope:
  # 
  #     post = Hive::Post.find_by_slug '@steemit/firstpost'
  # 
  # A post has many children, which are direct replies to that post.
  # 
  #     children = post.children
  # 
  # Each child post has a parent that links back to the post it is a reply
  # to:
  # 
  #     parent = children.first.parent
  # 
  # A post also has an account_record, which is the ActiveRecord version of the
  # account string:
  # 
  #     account = post.account_record
  # 
  # A post has many followers, which are the accounts that follow the author:
  # 
  #     followers = post.followers
  # 
  # A post belongs to a community, which can be accessed as community_record,
  # the ActiveRecord version of the community string:
  # 
  #     communit = post.community_record
  # 
  # A post has many flaggers, which are the accounts that have flagged this
  # post:
  # 
  #    flaggers = post.flaggers
  # 
  # A post has many rebloggers, which are the accounts that have reblogged this
  # post:
  # 
  #    rebloggers = post.rebloggers
  # 
  # A post has many promoters, which are the accounts that have promoted this
  # post:
  # 
  #     promoters = post.promoters
  # 
  # Scopes
  # ======
  # 
  # We can use these scopes to perform a lookup on posts:
  # 
  #     posts = Hive::Post.author 'alice'
  #     posts = Hive::Post.community 'steemit'
  #     posts = Hive::Post.category 'steemit'
  #     posts = Hive::Post.depth 0 # only returns root posts
  #     posts = Hive::Post.root_posts # same as depth 0
  # 
  # Replies can be queried by specifying depth greater than zero:
  # 
  #     replies = Hive::Post.depth 1..10 # only returns replies up to 10 in depth
  #     replies = Hive::Post.depth 1..255 # only returns replies
  #     replies = Hive::Post.replies # same as depth 1..255
  # 
  # We can also specify replies for a particular author, which is analogous to
  # all replies to an author on steemit.com (i.e.: https://steemit.com/@alice/recent-replies):
  # 
  #     replies = Hive::Post.replies(parent_author: 'alice')
  # 
  # We can query for posts that were reblogged by someone:
  #
  #     posts = Hive::Post.rebloggers('alice')
  # 
  # If we want to grab all of the posts that have *all* of these tags:
  # 
  #     posts = Hive::Post.tagged(all: %w(steemit steem video youtube))
  # 
  # Or we can grab all of the posts with *any* of these tags:
  #
  #     posts = Hive::Post.tagged(any: %w(steemit steem video youtube))
  # 
  # Or, which is the same as using any:
  #
  #     posts = Hive::Post.tagged(%w(steemit steem video youtube))
  # 
  # Here, we can find all of the posts that mention *all* of these accounts:
  # 
  #     posts = Hive::Post.mentioned(all: %w(alice bob))
  #
  # Or find all of the posts that mention *any* of these accounts:
  #
  #     posts = Hive::Post.mentioned(any: %w(alice bob))
  # 
  # We can order by (which automatically joins {Hive::PostsCache}):
  #
  #     posts = Hive::Post.order_by_payout(:asc)
  #     posts = Hive::Post.order_by_payout # same as order_by_payout(:asc)
  #     posts = Hive::Post.order_by_payout(:desc)
  #     posts = Hive::Post.order_by_children
  #     posts = Hive::Post.order_by_author_rep
  #     posts = Hive::Post.order_by_total_votes
  #     posts = Hive::Post.order_by_up_votes
  #     posts = Hive::Post.order_by_promoted
  #     posts = Hive::Post.order_by_created_at
  #     posts = Hive::Post.order_by_payout_at
  #     posts = Hive::Post.order_by_updated_at
  #     posts = Hive::Post.order_by_rshares # first result is the most flagged post!
  # 
  # Other scopes:
  # 
  #     posts = Hive::Post.deleted
  #     posts = Hive::Post.deleted(false)
  #     posts = Hive::Post.pinned
  #     posts = Hive::Post.pinned(false)
  #     posts = Hive::Post.muted
  #     posts = Hive::Post.muted(false)
  #     posts = Hive::Post.valid
  #     posts = Hive::Post.valid(false)
  #     posts = Hive::Post.promoted
  #     posts = Hive::Post.promoted(false)
  #     posts = Hive::Post.reblogged
  #     posts = Hive::Post.reblogged(false)
  #     posts = Hive::Post.after(7.days.ago)
  #     posts = Hive::Post.after(7.days.ago, invert: true)
  #     posts = Hive::Post.before(7.days.ago)
  #     posts = Hive::Post.before(7.days.ago, invert: true)
  #     posts = Hive::Post.updated_after(7.days.ago)
  #     posts = Hive::Post.updated_after(7.days.ago, invert: true)
  #     posts = Hive::Post.updated_before(7.days.ago)
  #     posts = Hive::Post.updated_before(7.days.ago, invert: true)
  #     posts = Hive::Post.payout_after(7.days.ago)
  #     posts = Hive::Post.payout_after(7.days.ago, invert: true)
  #     posts = Hive::Post.payout_before(7.days.ago)
  #     posts = Hive::Post.payout_before(7.days.ago, invert: true)
  #     posts = Hive::Post.payout_zero
  #     posts = Hive::Post.payout_zero(false)
  #     posts = Hive::Post.app('busy')
  #     posts = Hive::Post.app('busy', version: '1.0')
  #     posts = Hive::Post.app('busy', version: '1.0', invert: true)
  #     posts = Hive::Post.format('markdown')
  #     posts = Hive::Post.format('markdown', invert: false)
  # 
  # All scopes can be strung together, e.g.:
  # 
  #     posts = Hive::Post.root_posts.author('alice').promoted
  #     posts = Hive::Post.replies(parent_author: 'alice').community('steemit')
  #     posts = Hive::Post.category('steemit').depth(255).valid
  #     posts = Hive::Post.tagged(all: %w(radiator ruby)).where.not(author: 'inertia')
  #     posts = Hive::Post.mentioned(all: %w(inertia whatsup)).tagged(any: %w(community shoutout))
  # 
  # Most interesting queries (once your node is fully synchronized):
  # 
  #     Hive::Post.order_by_rshares.deleted.first # o_O mfw
  class Post < Base
    # Blockchain limit on depth.
    MAX_HARD_DEPTH = 65535
    # Witness limit on depth.
    MAX_SOFT_DEPTH = 255
    
    self.table_name = :hive_posts
    
    has_one :cache, class_name: 'PostsCache'
    belongs_to :parent, class_name: 'Post'
    has_many :children, -> { depth(1..MAX_SOFT_DEPTH) },
      inverse_of: 'parent', foreign_key: :parent_id, class_name: 'Post'
    
    belongs_to :author_account, primary_key: :name, foreign_key: :author, class_name: 'Account'
    has_many :followers, through: :author_account, source: :followers
    
    belongs_to :community_record, primary_key: :name, foreign_key: :community, class_name: 'Community'
    has_many :community_members, through: :community_record, source: :members
    has_many :community_accounts, through: :community_record, source: :accounts

    has_many :flags
    has_many :flaggers, through: :flags, source: :account_record
    has_many :reblogs
    has_many :rebloggers, through: :reblogs
    has_many :post_tags
    
    has_many :payments
    has_many :promoters, through: :payments, source: :from
    
    has_many :feed_cache
    has_many :feed_accounts, through: :feed_cache, source: :account
    
    scope :author, lambda { |author| where(author: author) }
    scope :community, lambda { |community| where(community: community) }
    scope :category, lambda { |category| where(category: category) }
    scope :depth, lambda { |depth, options = {invert: false}|
      r = if depth == 0
        where(depth: depth, parent: nil)
      else
        where(depth: depth).where.not(parent: nil)
      end
      
      r = all.where.not(id: r) if !!options[:invert]
      
      r
    }
    scope :root_posts, -> { depth(0) }
    scope :replies, lambda { |options = {invert: false}|
      r = depth(1..MAX_SOFT_DEPTH)
      
      if !!options[:parent_author] || !!options[:parent_permlink]
        parent_posts = all
        
        if !!options[:parent_author]
          parent_author = Post::transform_account_selector options[:parent_author]
          parent_posts = parent_posts.where(author: parent_author)
        end
        
        if !!options[:parent_permlink]
          parent_posts = parent_posts.where(permlink: options[:parent_permlink])
        end
        
        r = r.where(parent_id: parent_posts)
      end
      
      r = all.where.not(id: r) if !!options[:invert]
      
      r
    }
    scope :deleted, lambda { |deleted = true| where(is_deleted: deleted) }
    scope :pinned, lambda { |pinned = true| where(is_pinned: pinned) }
    scope :muted, lambda { |muted = true| where(is_muted: muted) }
    scope :valid, lambda { |valid = true| where(is_valid: valid) }
    scope :promoted, lambda { |promoted = true|
      if promoted
        where.not(promoted: 0.0)
      else
        where(promoted: 0.0)
      end
    }
    scope :reblogged, lambda { |reblogged = true|
      if reblogged
        where(id: Reblog.select(:post_id))
      else
        where.not(id: Reblog.select(:post_id))
      end
    }
    scope :rebloggers, lambda { |rebloggers = []|
      reblogs = Reblog.where(account: rebloggers)
      reblogged.where(id: reblogs.select(:post_id))
    }
    
    scope :feed_cache, lambda { |account, options = {invert: false}|
      r = if account.is_a? ActiveRecord::Relation
        root_posts.joins(:feed_cache).
          where('hive_feed_cache.account_id IN(?)', account.select(:id))
      else
        account = Post::transform_account_selector account
        root_posts.joins(:author_account, :feed_cache).
          where('hive_accounts.name IN(?)', account)
      end
      
      if !!options[:invert]
        all.root_posts.where.not(id: r)
      else
        r
      end
    }
    
    
    scope :feed, lambda { |account, options = {invert: false}|
      account = Post::transform_account_selector account
      r = root_posts.joins(:author_account, :rebloggers).
        where('hive_accounts.name IN(?) OR hive_reblogs.account IN(?)', account, account)
      
      if !!options[:invert]
        all.root_posts.where.not(id: r)
      else
        r
      end
    }
    
    scope :tagged, lambda { |*args|
      options = if args[0].nil? || args[0].is_a?(Hash)
        args[0] || {}
      else
        {any: args}
      end
      relation = all
      
      if !!options[:all]
        [options[:all]].flatten.map do |tag|
          selector = Hive::PostTag.where(tag: tag).select(:post_id)
          relation = relation.where(id: selector)
        end
      end
      
      if !!options[:any]
        relation = relation.where(id: Hive::PostTag.where(tag: [options[:any]].flatten).select(:post_id))
      end
      
      if !!options[:invert]
        where.not(id: relation)
      else
        relation
      end
    }
    
    scope :mentioned, lambda { |options = {}|
      where(id: Hive::PostsCache.mentioned(options).select(:post_id))
    }
    
    scope :after, lambda { |after, options = {invert: false}|
      invertable 'hive_posts.created_at > ?', after, options
    }
    
    scope :before, lambda { |before, options = {invert: false}|
      invertable 'hive_posts.created_at < ?', before, options
    }
    
    scope :updated_after, lambda { |after, options = {invert: false}|
      where(id: Hive::PostsCache.updated_after(after, options).select(:post_id))
    }
    
    scope :updated_before, lambda { |before, options = {invert: false}|
      where(id: Hive::PostsCache.updated_before(before, options).select(:post_id))
    }
    
    scope :payout_after, lambda { |after, options = {invert: false}|
      where(id: Hive::PostsCache.payout_after(after, options).select(:post_id))
    }
    
    scope :payout_before, lambda { |before, options = {invert: false}|
      where(id: Hive::PostsCache.payout_before(before, options).select(:post_id))
    }
    
    scope :payout_zero, lambda { |payout_zero = true|
      where(id: Hive::PostsCache.payout_zero(payout_zero).select(:post_id))
    }
    
    scope :app, lambda { |app, options = {version: nil, invert: false}|
      where(id: Hive::PostsCache.app(app, options).select(:post_id))
    }
    
    scope :format, lambda { |format, options = {invert: false}|
      where(id: Hive::PostsCache.format(format, options).select(:post_id))
    }
    
    scope :order_by_cache, lambda { |*args|
      field = args[0].keys.first rescue raise('Order field must be specified.')
      direction = args[0].values.first || :asc
      table = Hive::PostsCache.arel_table
      
      joins(:cache).order(table[field.to_sym].send(direction.to_sym))
    }
    
    scope :order_by_feed_cache, lambda { |*args|
      field = args[0].keys.first rescue raise('Order field must be specified.')
      direction = args[0].values.first || :asc
      table = Hive::FeedCache.arel_table
      
      joins(:feed_cache).order(table[field.to_sym].send(direction.to_sym))
    }
    
    scope :order_by_payout, lambda { |*args| order_by_cache(payout: args[0] || :asc) }
    scope :order_by_children, lambda { |*args| order_by_cache(children: args[0] || :asc) }
    scope :order_by_author_rep, lambda { |*args| order_by_cache(author_rep: args[0] || :asc) }
    scope :order_by_total_votes, lambda { |*args| order_by_cache(total_votes: args[0] || :asc) }
    scope :order_by_up_votes, lambda { |*args| order_by_cache(up_votes: args[0] || :asc) }
    scope :order_by_promoted, lambda { |*args| order_by_cache(promoted: args[0] || :asc) }
    scope :order_by_created_at, lambda { |*args| order_by_cache(created_at: args[0] || :asc) }
    scope :order_by_payout_at, lambda { |*args| order_by_cache(payout_at: args[0] || :asc) }
    scope :order_by_updated_at, lambda { |*args| order_by_cache(updated_at: args[0] || :asc) }
    scope :order_by_rshares, lambda { |*args| order_by_cache(rshares: args[0] || :asc) }
    scope :order_by_feed_cache_created_at, lambda { |*args| order_by_feed_cache(created_at: args[0] || :asc) }
    
    # Finds a post by slug (or even URL).
    #
    # @param slug String A composite of author and permlink that uniquely identifies a post.  E.g.: "@steemit/firstpost"
    # @return <Hive::Post>
    def self.find_by_slug(slug)
      slug = slug.split('@').last
      slug = slug.split('/')
      author = slug[0]
      permlink = slug[1..-1].join('/')
      
      Post.where(author: author, permlink: permlink).first
    end
    
    # All tags related to this post.
    # 
    # @return <String>
    def tags; post_tags.pluck(:tag); end
    
    # The entire discussion related to this post including all children and
    # grandchildren replies (the result also includes this post).
    # 
    # @return {ActiveRecord::Relation}
    def discussion
      clause = <<-DONE
        hive_posts.community = ?
        AND hive_posts.category = ?
        AND hive_posts.id >= ?
        AND hive_posts.id IN(?)
      DONE
      
      Post.deleted(false).
        where(clause, community, category, id, discussion_ids)
    end
    
    # Returns the unique string containing the author and permlink, useful in
    # restful development as param_id, if desired.
    # 
    # @return String
    def slug
      "@#{author}/#{permlink}"
    end
  private
    # @private
    def discussion_ids(ids = [id])
      new_ids = Post.deleted(false).depth(1..MAX_SOFT_DEPTH).
        where(community: community, category: category).
        where(parent_id: ids).pluck(:id)
      
      ids += new_ids + discussion_ids(new_ids) if new_ids.any?
      
      ids.uniq.compact
    end
  end
end
