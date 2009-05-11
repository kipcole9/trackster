module Analytics
  module Metrics
    def self.included(base)
      base.class_eval do
        
        # Pages_views is derived directly from session data
        named_scope :page_views,
          :select => "sum(page_views) as page_views",
          :include => :events

        # Can only count sessions that have visitors (ie. view javascript)
        named_scope :visitors,
          :select => :visitor,
          :conditions => "visitor IS NOT NULL",
          :group => :visitor

        # Each session is a visit
        named_scope :visits, {}

        # Visitors for whom this was their first visit
        named_scope :new_visitors,
          :conditions => "visit = 1" 

        # Visitors who have visited more than once in the current period
        # Without further scoping this is meaningless - but the #between scope
        # needs to see this first
        named_scope :repeat_visitors,
          :select => :visitor,
          :conditions => "previous_visit_at IS NOT NULL", 
          :group => :visitor

        named_scope :repeat_visits,
          :conditions => "previous_visit_at IS NOT NULL"

        # Visitors who visited before the current period and have now returned
        # Needs to be scoped with previous_visit_at before a relevant period
        named_scope :return_visitors,
          :select => :visitor,
          :conditions => "previous_visit_at IS NOT NULL", 
          :group => :visitor

        named_scope :return_visits,   
          :conditions => "visit > 1 AND previous_visit_at IS NOT NULL"

        # Entry page is marked in the events table
        named_scope :entry_pages,
          :include => :events, :conditions => 'events.entry_page = 1'
    
        # Landing page is the same as an entry page - but in a campaign
        # context
        named_scope :landing_pages, 
          :include => :events, :conditions => "events.entry_page = 1 and url IS NOT NULL and campaign_name IS NOT NULL"

        named_scope :exit_pages,
          :include => :events, :conditions => "events.exit_page = 1"

        # Duration is marked in the Session table for the total of the session
        named_scope :duration,
          :conditions => "duration IS NOT NULL"

        named_scope :bounces, :conditions => "page_views = 1" do
          def rate
            number = count
            entries = entry_pages.count
            number / entries
          end
        end
      end
    end
  end
end