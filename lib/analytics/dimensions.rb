module Analytics
  module Dimensions
    def self.included(base)
      base.class_eval do

        named_scope :between, lambda {|*args|
          return {} unless args.last
          range = args.last
          this_scope = "tracked_at BETWEEN '#{range.first.to_s(:db)}' AND '#{range.last.to_s(:db)}'"
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
          args.each do |dimension|
            case dimension.to_sym
            when :day
              select << "date(tracked_at) as tracked_at"
              group << "date(tracked_at)"
            when :month
              select << "date_format(tracked_at, '%Y/%m/1') as tracked_at"
              group << "year(tracked_at), month(tracked_at)"
            when :year
              select << "date_format(tracked_at, '%Y/1/1') as tracked_at"
              group << "year(tracked_at)"
            when :hour
              select << "date_format(tracked_at, '%Y/%m/%d %k:00:00') as tracked_at"
              group << "day(tracked_at), hour(tracked_at)"
            else
              Session.respond_to?(dimension) ? select << dimension.to_s : select << "#{dimension.to_s}"
              group << dimension.to_s      
            end
          end
          select << "count(*) as id"
          {:joins => :events, :select => select.join(', '), :group => group.join(', ')}
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

        non_metrics_keys = [:scoped, :source, :between, :by, :duration, :campaign, :medium].freeze
        def self.available_metrics
          @@available_metrics = nil unless defined?(@@available_metrics)
          return  @@available_metrics || 
                  @@available_metrics = self.scopes.keys.reject{|k| non_metric_keys.include? k }.map(&:to_s)
        end
      end
    end
  end
end