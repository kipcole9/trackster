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
            :conditions => "category = '#{Event::PAGE_CATEGORY}' AND action = '#{Event::VIEW_ACTION}' AND url IS NOT NULL",
            :joins => :events}
          else
            {:select => "sum(page_views) as page_views",
             :conditions => "session IS NOT NULL"}
          end
        }
        
        named_scope :page_views_per_visit, lambda{ |*args|
          if args.first && args.first == :with_events
            {:select => "avg(*) as page_views_per_visit",
            :conditions => "category = '#{Event::PAGE_CATEGORY}' AND action = '#{Event::VIEW_ACTION}' AND url IS NOT NULL",
            :joins => :events}
          else
            {:select => "avg(page_views) as page_views_per_visit"}
          end
        }

        named_scope :video_views,
          :select => "count(*) as video_views",
          :conditions => "events.category = '#{Event::VIDEO_CATEGORY}' and events.action = '#{Event::VIDEO_PLAY}'",
          :joins => :events
            
        # Maximum view time of a video
        named_scope :video_playtime,
          :select => "max(events.value) as maxplay",
          :conditions => "events.category = '#{Event::VIDEO_CATEGORY}' AND events.action = '#{Event::VIDEO_MAXPLAY}'",
          :joins => :events

        # Can only count sessions that have visitors
        named_scope :visitors,
          :select => 'count(DISTINCT visitor) as visitors'

        # Each session is a visit
        named_scope :visits,
          :select => 'count(visit) as visits'

        # Visitors for whom this was their first visit
        named_scope :new_visits,
          :select => 'count(if(visit=1,1,null)) as new_visits'

        named_scope :new_visit_rate,
          :select => 'count(if(visit=1,1,null)) / count(*) * 100 as new_visit_rate'
        
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
          :select => 'count(if(visit > 1,1,null)) as return_visits'

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
                 
        named_scope :clicks_through,
          :select => 'count(*) as clicks_through',
          :conditions => "campaign_medium = 'email' AND campaign_name IS NOT NULL"

        # Duration is marked in the Session table for the total of the session
        named_scope :duration,
          :select => 'avg(sessions.duration) as duration'
          
        named_scope :page_duration,
          :select => 'avg(events.duration) as duration'

        named_scope :bounces,
          :select => 'count(if(sessions.duration=0,1,null)) AS bounces'
          
        named_scope :bounce_rate,
          :select => 'count(if(sessions.duration=0,1,null)) / count(*) * 100 as bounce_rate'
          
        named_scope :impressions,
          :select => 'count(*) as impressions',
          :conditions => "category = '#{Event::EMAIL_CATEGORY}' AND action = '#{Event::OPEN_ACTION}'",
          :joins => :events

        named_scope :latency, 
          :select => "CAST(AVG(time_to_sec(events.created_at) - time_to_sec(tracked_at)) AS signed) AS latency",
          :conditions => 'events.created_at IS NOT NULL AND events.tracked_at IS NOT NULL',
          :joins => :events
                   
      end
    end
  end
end