module Analytics
  module Model
    module Dimensions
      def self.included(base)
        base.class_eval do
        
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
          
          named_scope   :referrer_category,
            :select => 'referrer_category',
            :group => 'referrer_category'
          
          named_scope   :keywords,
            :select => 'search_terms',
            :conditions => 'search_terms IS NOT NULL',
            :group => 'search_terms'
          
          named_scope   :device,
            :select => 'trim(concat(if(isnull(device_vendor),\'\',device_vendor), \' \', device)) as device',
            :group => 'device'
          
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

          # Here we categorise the dimensions. The categories are defined so that
          #
          # 1. We know if we have to join the events table and not just use the sessions table
          # 2. We can decide what our baseline report will be (visit summary, visitor summary, ....)

          # Dimensions that are based only on the sessions table
          # Used in site reporting
          def self.session_dimensions
            unless defined?(@@session_dimensions)
              @@session_dimensions = self.columns_hash.inject([]) { |array, item| array << item.first }
              @@session_dimensions.reject{|k| k =~ /(_(id|at)|\Aid|user_agent|referrer|event_count|page_views)\Z/ }
              @@session_dimensions << ['new_v_returning','traffic_source','keywords']
              @@session_dimensions.flatten!
            end
            @@session_dimensions
          end
        
          # Dimensions that require joining the events table
          def self.event_dimensions
            unless defined?(@@event_dimensions)
              @@event_dimensions = Event.columns_hash.inject([]) { |array, item| array << item.first }
              @@event_dimensions.reject{|k| k =~ /(_(id|at)|\Aid)\Z/ }
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
end