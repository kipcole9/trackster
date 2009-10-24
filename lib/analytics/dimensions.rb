module Analytics
  module Dimensions
    def self.included(base)
      base.class_eval do
        named_scope :between, lambda {|*args|
          return {} unless args.last
          range = args.last
          this_scope = "started_at BETWEEN '#{range.first.to_s(:db)}' AND '#{range.last.to_s(:db)}'"
          parent_scope = self.scoped_methods.last[:find] unless self.scoped_methods.last.nil?
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
            dim = dim.to_sym
            if self.scopes[dim]
              # It's a named scope
              scope_options = self.send(dim).proxy_options
              select << scope_options[:select]  if scope_options[:select]
              group << scope_options[:group]    if scope_options[:group]
              conditions << scope_options[:conditions] if scope_options[:conditions]
              joins << scope_options[:joins]    if scope_options[:joins]
            else
              dimension = dim.to_s
              select << dimension
              group << dimension
              conditions << "#{dimension} IS NOT NULL" if non_null_dimensions.include?(dim)
              joins << :events if Event.columns_hash[dimension.to_s]
            end
          end
          {:select => select.join(', '), :conditions => conditions.uniq.join(' AND '), :group => group.uniq.join(', '), :joins => joins.uniq}
        }
        
        named_scope   :new_v_returning,
          :select => "if(visit=1,'new','returning') AS visit_type",
          :group => "visit_type"
          
        named_scope   :entry_page,
          :select => 'url',
          :conditions => 'entry_page = 1 and exit_page = 0',
          :group => 'url'

        named_scope   :exit_page,
          :select => 'url',
          :conditions => 'entry_page = 0 and exit_page = 1',
          :group => 'url'

        named_scope   :bounce_page,
          :select => 'url',
          :conditions => 'entry_page = 1 and exit_page = 1',
          :group => 'url'

        named_scope   :traffic_source,
          :select => 'referrer_host, traffic_source',
          :group => 'referrer_host, traffic_source'
          
        named_scope   :keywords,
          :select => 'search_terms',
          :conditions => 'search_terms IS NOT NULL',
          :group => 'search_terms'
          
        named_scope   :length_of_visit, lambda {
          visit_sql = <<-SELECT
            if(duration <= 10, '0-10',
              if(duration > 10 and duration < 30, '11-20',
                if(duration > 30 and duration < 60, '31-60', 
                  if(duration > 60 and duration < 180, '61-180',
                    if(duration > 180 and duration < 600, '181-600',
                      if(duration > 600 and duration < 1800, '601-1800', '1800+')
                    )
                  )
                )
              )
            )  as length_of_visit
          SELECT
          {:select => visit_sql, :group => :length_of_visit, :order => :length_of_visit}
        }
        
        named_scope   :max_play_time, lambda{
          {
            :select => "(cast(value / 5 as unsigned) * 5)  as max_play_time", :group => :max_play_time, :order => :max_play_time,
            :conditions => Event::VIDEO_MAXVIEW
          }
        }
        
        named_scope   :depth_of_visit, lambda {
          visit_sql = <<-SELECT
            if(page_views < 20, page_views, '20+') as depth_of_visit
          SELECT
          {:select => visit_sql, :group => :depth_of_visit, :order => :depth_of_visit}
        }

        named_scope   :campaign_name,
          :select => 'name as campaign_name',
          :joins => :campaign,
          :group => 'campaign_name'
          
        def self.non_null_dimensions
          self::NON_NULL_DIMENSIONS
        end

        # Dimensions that are based only on the sessions table
        # Used in site reporting
        def self.session_dimensions
          unless defined?(@@session_dimensions)
            @@session_dimensions = self.columns_hash.inject([]) { |array, item| array << item.first }
            @@session_dimensions.reject{|k| k =~ /(_(id|at)|id|user_agent|referrer|event_count|page_views)\Z/ }
            @@session_dimensions << ['new_v_returning','traffic_source','keywords']
            @@session_dimensions.flatten!
          end
          @@session_dimensions
        end
        
        # Dimensions that require joining the events table
        def self.event_dimensions
          unless defined?(@@event_dimensions)
            @@event_dimensions = Event.columns_hash.inject([]) { |array, item| array << item.first }
            @@event_dimensions.reject{|k| k =~ /(_(id|at)|id)\Z/ }
            @@event_dimensions << ['bounce_page']
            @@event_dimensions.flatten!         
          end
          @@event_dimensions          
        end
        
        # Dimensions that require joining the events table
        def self.loyalty_dimensions
          unless defined?(@@loyalty_dimensions)
            @@loyalty_dimensions = ['length_of_visit','recency_of_visit','depth_of_visit','loyalty']     
          end
          @@loyalty_dimensions          
        end
        
        def self.campaign_dimensions
          unless defined?(@@campaign_dimensions)
            @@campaign_dimensions = ['campaign_overview']     
          end
          @@campaign_dimensions          
        end        
        
        def self.available_metrics
          @@available_metrics = nil unless defined?(@@available_metrics)
          @@available_metrics || @@available_metrics = self.scopes.keys.reject{|k| NON_METRIC_KEYS.include? k }.map(&:to_s)
        end
        
        def self.valid_metric?(key)
          self.available_metrics.include?(key.to_s)
        end
      end
    end
  end
end