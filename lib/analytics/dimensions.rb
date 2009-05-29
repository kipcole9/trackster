module Analytics
  module Dimensions
    def self.included(base)
      base.class_eval do
        named_scope :between, lambda {|*args|
          return {} unless args.last
          range = args.last
          this_scope = "started_at BETWEEN '#{range.first.to_s(:db)}' AND '#{range.last.to_s(:db)}'"
          parent_scope = self.scoped_methods.last[:find]
          if parent_scope == self.repeat_visitors.proxy_options ||
             parent_scope == self.repeat_visits.proxy_options
            this_scope += " AND previous_visit_at > '#{range.first.to_s(:db)}'"
          end
          if parent_scope == self.return_visitors.proxy_options ||
             parent_scope == self.return_visits.proxy_options
            this_scope += " AND previous_visit_at < '#{range.first.to_s(:db)}'"
          end
          {:conditions => this_scope}
        }

        named_scope :by, lambda {|*args|
          return {} unless args.last
          args = args.last.flatten if args.last.is_a?(Array)
  
          # Args are passed as SELECT and GROUP clauses
          # with special attention paid to :day, :month, :year, :hour
          # configurations because they manipulate the #tracked_at formation
          #
          # Note that this also controls the grouping since we add each
          # argument to both the SELECT and GROUP.  This simplifies reporting
          # on either aggregate events (ie. 43 page views this month) versus
          # more fine-grained reporting.
          select = []
          group = []
          joins = []
          conditions = []
          args.each do |dim|
            dimension = dim.to_s
            select << dimension
            group << dimension
            conditions << "#{dimension} IS NOT NULL" if non_null_dimensions.include?(dim)
            joins << :events if Event.columns_hash[dimension.to_s]
          end
          {:select => select.join(', '), :conditions => conditions.join(' AND '), :group => group.join(', '), :joins => joins}
        }

        # => Campaign scoping
        named_scope   :campaign, lambda {|campaign|
          {:conditions => {:campaign_name => campaign}}
        }
          
        named_scope   :source, lambda {|source|
          {:conditions => {:campaign_source => source}}
        }         

        named_scope   :medium, lambda {|method|
          {:conditions => {:campaign_medium => method}}
        }
        
        named_scope   :label, lambda {|label|
          {:conditions => ["events.label = ?", label]}
        }

        def self.non_null_dimensions
          @@non_null_dimensions = [:referrer, :search_terms, :referrer_host] unless defined?(@@non_null_dimensions)
          @@non_null_dimensions
        end
        
        def self.available_metrics
          @@non_metric_keys = [:scoped, :source, :between, :by, :duration, :campaign, :medium, :source, :order, :label, :filter].freeze unless defined?(@@non_metric_keys)
          @@available_metrics = nil unless defined?(@@available_metrics)
          return  @@available_metrics || 
                  @@available_metrics = self.scopes.keys.reject{|k| @@non_metric_keys.include? k }.map(&:to_s)
        end
        
        def self.valid_metric?(key)
          self.available_metrics.include?(key.to_s)
        end
      end
    end
  end
end