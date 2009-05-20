class Session < ActiveRecord::Base
  has_many      :events
  belongs_to    :property
  belongs_to    :account
  before_create :update_time_metrics
  before_create :update_traffic_source
  before_save   :update_session_time
  before_save   :update_event_count
  
  def self.find_or_create_from_track(row)
    if row[:visitor] && row[:visit] && row[:session]
      session = find_by_visitor_and_visit_and_session(row[:visitor], row[:visit], row[:session])
    end
    session = self.new_from_row(row) unless session
    session
  end
  
  # To trigger before_save viewcount updating
  def update_viewcount!
    self.save!
  end
  
  def referrer=(r)
    return if r.blank? || r == '-'
    super
  end

  def update_time_metrics
    self.date   = self.started_at.to_date
    self.week   = self.date.cweek
    self.hour   = self.started_at.hour
    self.day    = self.started_at.day
    self.month  = self.started_at.month
    self.year   = self.started_at.year
  end
  
private
  def self.new_from_row(row)
    session = new
    
    # Copy the common attributes from the tracker row
    session.attributes.each do |k, v|
      session.send("#{k.to_s}=",  row[k.to_sym])
    end
    session.started_at  = row[:tracked_at]
    session.ended_at    = session.started_at 
    
    # See if there was a previous session
    if session.visit && session.visit > 1 && previous_visit = find_by_visitor_and_visit(session.visitor, session.visit - 1)
      session.previous_visit_at = previous_visit.started_at
    end
    
    # Note session relevant data.  Session must be
    # tied to a site else it's a bogus sesssion
    if session.property = Property.find_by_tracker(row[:property_code])
      session.account = session.property.account
    end
    session.property ? session : nil
  end
  
  def update_event_count
    self.event_count = self.events.count
    self.page_views = self.events.count(:conditions => ["category = 'page' AND action = 'view' AND url IS NOT NULL"])
  end
  
  def update_session_time
    self.duration = (self.ended_at - self.started_at).to_i
  end

  def update_traffic_source
    if self.referrer_host && source = self.account.traffic_sources.find_by_host(self.referrer_host)
      self.traffic_source = source.source_type
    end
  end
end
