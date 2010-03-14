module Analytics
  module Metrics
    def self.included(base)
      base.class_eval do
        # Pages_views calculated because following dimensions may include
        # events anyway and the cross-product of the two tables will
        # mess up totals.
        named_scope :page_views, lambda{ |*args|
          if args.first && args.first == :with_events
            {:select => "count(*) as page_views",
            :conditions => "page_view = 1",
            :joins => :events}
          else
            {:select => "sum(page_views) as page_views"}
          end
        }
        
        named_scope :page_views_per_visit, lambda{ |*args|
          if args.first && args.first == :with_events
            {:select => "avg(*) as page_views_per_visit",
            :conditions => Event::PAGE_VIEW,
            :joins => :events}
          else
            {:select => "avg(page_views) as page_views_per_visit"}
          end
        }

        named_scope :video_views,
          :select => "count(*) as video_views",
          :conditions => Event::VIDEO_MAXVIEW,
          :joins => :events
            
        # Maximum view time of a video
        named_scope :video_playtime,
          :select => "max(events.value) as maxplay",
          :conditions => Event::VIDEO_MAXVIEW,
          :joins => :events

        # Can only count sessions that have visitors
        named_scope :visitors,
          :select => 'count(DISTINCT visitor) as visitors'

        # Each session is a visit
        named_scope :visits,
          :select => 'count(visit) as visits',
          :conditions => 'visit IS NOT NULL'
          
        # TODO Want to show average number of visits for day of the week in the given period.    
        named_scope :average_visits,
          :select => 'count(visit) as visits',
          :conditions => 'visit IS NOT NULL'
            
        # Named to avoid name class with association
        named_scope :event_count, lambda{ |*args|
          if args.first && args.first == :with_events
            {:select => "count(action) as event_count",
            :joins => :events}
          else
            { :select => 'avg(event_count - page_views) as event_count' }
          end
        }
          
        named_scope :value,
          :select => 'avg(value) as value'

        # Visitors for whom this was their first visit
        named_scope :new_visits,
          :select => 'count(if(visit=1,1,null)) as new_visits'

        named_scope :new_visit_rate,
          :select => 'count(if(visit=1,1,null)) / count(if(visit>0,1,NULL)) * 100 as new_visit_rate'
        
        # Visitors who have visited more than once in the current period
        # Without further scoping this is meaningless - but the #between scope
        # needs to see this first
        named_scope :repeat_visitors,
          :select => 'count(DISTINCT visitor) as repeat_visitors',
          :conditions => "previous_visit_at IS NOT NULL"

        named_scope :repeat_visits,
          :select => 'count(*) as repeat_visits',
          :conditions => "previous_visit_at IS NOT NULL"

        # Visitors who visited before the current period and have now returned
        # Needs to be scoped with previous_visit_at before a relevant period
        named_scope :return_visitors,
          :select => 'count(DISTINCT visitor) as return_visitors',
          :conditions => "previous_visit_at IS NOT NULL"

        named_scope :return_visits,
          :select => 'count(if(visit>1,1,null)) as return_visits'

        # Entry page is marked in the events table
        named_scope :entry_pages,
          :select => 'count(if(entry_page=1,1,null)) as entry_pages',
          :joins => :events
          
        named_scope :entry_rate,
          :select => 'count(if(entry_page = 1 AND exit_page = 0,1,NULL)) / count(*) * 100 as entry_rate',
          :joins => :events      
    
        named_scope :exit_pages,
          :select => 'count(if(exit_page=1,1,null)) as exit_pages',
          :joins => :events

        named_scope :exit_rate,
          :select => 'count(if(exit_page=1 AND entry_page = 0,1,NULL)) / count(*) * 100 as exit_rate',
          :joins => :events
          
        # Landing page is the same as an entry page - but in a campaign
        # context
        named_scope :landing_pages,
          :select => 'count(*) as landing_pages',
          :conditions => "entry_page = 1 and url IS NOT NULL and campaign_name IS NOT NULL",
          :joins => :events
        
        @@bounces = "if(sessions.duration=0,1,null))"
        named_scope :bounces,
          :select => "count(#{@@bounces}) AS bounces"
                  
        named_scope :bounce_rate,
          :select => "count(#{@@bounces}/ count(visit) * 100 as bounce_rate"

        # For email deliveries
        @@impressions = "sum(impressions)"
        named_scope :impressions,
          :select => "#{@@impressions} as impressions"
                             
        @@clicks_through =  "count(if(campaign_medium IS NOT NULL AND page_views > 0,1,NULL))"                    
        named_scope :clicks_through,
          :select => "#{@@clicks_through} as clicks_through"
          
        named_scope :click_through_rate,
          :select => "(#{@@clicks_through} / #{@@impressions} * 100) as click_through_rate"
          
        named_scope :open_rate,
          :select => "(#{@@impressions} / distribution * 100) as open_rate",
          :joins => :campaign

        @@cost =  'avg(cost)'    
        named_scope :cost,
          :select => "#{@@cost} as cost",
          :joins => :campaign
          
        named_scope :cost_per_click,
          :select => "(#{@@cost} / #{@@clicks_through}) as cost_per_click"

        # Duration is marked in the Session table for the total of the session
        named_scope :duration,
          :select => 'avg(sessions.duration) as duration'
          
        named_scope :page_duration,
          :select => 'avg(events.duration) as duration'

        named_scope :deliveries,
          :select => 'avg(distribution - bounces - unsubscribes) as deliveries',
          :joins => :campaign

        named_scope :cost_per_impression,
          :select => "(#{@@cost}/#{@@impressions}) as cost_per_impression"

        named_scope :campaign_bounces,
          :select => 'avg(bounces) as bounces',
          :joins => :campaign
          
        named_scope :unsubscribes,
          :select => 'avg(unsubscribes) as unsubscribes',
          :joins => :campaign

        named_scope :distribution,
          :select => 'avg(distribution) as distribution',
          :joins => :campaign

        # How long between the event and it turning up in the log
        named_scope :latency, 
          :select => "CAST(AVG(abs(timestampdiff(second, events.created_at, tracked_at) - (timezone * 60))) AS signed) AS latency",
          :conditions => 'events.created_at IS NOT NULL AND events.tracked_at IS NOT NULL',
          :joins => :events
                   
      end
    end
  end
end