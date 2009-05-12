module Analytics
  module Metrics
    def self.included(base)
      base.class_eval do

        # Pages_views is derived directly from session data
        named_scope :page_views,
          :select => "count(*) as count",
          :conditions => "category = 'page' and action = 'view'"

        named_scope :video_views,
          :select => "count(*) as count",
          :conditions => "category = 'video' and action = 'play'"
            
        # Pages_views is derived directly from session data
        named_scope :video_playtime,
          :select => "max(value) as value",
          :conditions => "category = 'video' and (action = 'pause' or action = 'end')",
          :group => "session_id"

        # Can only count sessions that have visitors (ie. view javascript)
        named_scope :visitors,
          :select => 'count(DISTINCT visitor) as count',
          :conditions => "visitor IS NOT NULL"

        # Each session is a visit
        named_scope :visits,
          :select => 'count(*) as count',
          :conditions => "sequence = 1"

        # Visitors for whom this was their first visit
        named_scope :new_visitors,
          :select => 'count(*) as count',
          :conditions => "visit = 1 and entry_page = 1" 

        # Visitors who have visited more than once in the current period
        # Without further scoping this is meaningless - but the #between scope
        # needs to see this first
        named_scope :repeat_visitors,
          :select => 'count(DISTINCT visitor) as count',
          :conditions => "entry_page = 1 and previous_visit_at IS NOT NULL"

        named_scope :repeat_visits,
          :select => 'count(*) as count',
          :conditions => "entry_page = 1 and previous_visit_at IS NOT NULL"

        # Visitors who visited before the current period and have now returned
        # Needs to be scoped with previous_visit_at before a relevant period
        named_scope :return_visitors,
          :select => 'count(DISTINCT visitor) as count',
          :conditions => "entry_page = 1 and previous_visit_at IS NOT NULL"

        named_scope :return_visits,
          :select => 'count(*) as count',
          :conditions => "visit > 1 and entry_page = 1 AND previous_visit_at IS NOT NULL"

        # Entry page is marked in the events table
        named_scope :entry_pages,
          :select => 'count(*) as count',
          :conditions => 'entry_page = 1'
    
        # Landing page is the same as an entry page - but in a campaign
        # context
        named_scope :landing_pages,
          :select => 'count(*) as count',
          :conditions => "entry_page = 1 and url IS NOT NULL and campaign_name IS NOT NULL"

        named_scope :exit_pages,
          :select => 'count(*) as count',
          :conditions => "exit_page = 1"

        # Duration is marked in the Session table for the total of the session
        named_scope :duration,
          :select => 'sum(duration) as duration',
          :conditions => "duration > 0 and exit_page = 1"

        named_scope :bounces,
          :select => 'count(*) as count',
          :conditions => 'sequence = 1 and duration = 0'  do
        end
      end
    end
  end
end