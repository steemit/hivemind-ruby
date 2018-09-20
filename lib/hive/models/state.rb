module Hive
  
  # Tracks state.
  class State < Base
    cattr_reader :methods
    self.table_name = :hive_state
    
    @@methods = %i(
      block_num db_version steem_per_mvest usd_per_steem sbd_per_steem dgpo
    )
    
    def self.respond_to_missing?(m, include_private = false)
      methods.include? m.to_sym
    end

    def self.method_missing(m, *args, &block)
      super unless respond_to_missing?(m)
      
      case m
      when :dgpo
        dgpo = JSON[last.send :dgpo]
        
        dgpo.each do |k, v|
          case v
          when Hash
            dgpo[k] = Struct.new(*v.keys.map(&:to_sym)).new(*v.values)
          when String
            if v =~ /^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[0-1]|0[1-9]|[1-2][0-9])T(2[0-3]|[0-1][0-9]):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?(Z|[+-](?:2[0-3]|[0-1][0-9]):[0-5][0-9])?$/
              dgpo[k] = Time.parse(v + 'Z') rescue v
            elsif v =~ /[0-9]+/
              dgpo[k] = v.to_i
            end
          end
        end
        
        dgpo = Struct.new(*dgpo.keys.map(&:to_sym)).new(*dgpo.values)
      else; last.send(m)
      end
    end
  end
end
