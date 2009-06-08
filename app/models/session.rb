class Session < ActiveRecord::Base
  has_many      :events, :dependent => :destroy
  belongs_to    :property
  belongs_to    :account
  belongs_to    :campaign
  
  before_create :update_traffic_source
  before_create :update_local_hour
  before_save   :update_session_time
  before_save   :update_event_count
  
  EMAIL_CLICK   = 'email'
  
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
  
  def flash_version=(r)
    return if r.blank? || r == '-'
    super
  end

  def language=(l)
    return if l.blank?
    super(l.downcase)
  end

  def save_time_metrics(row)
    self.date   = self.started_at.to_date
    self.day_of_week = self.started_at.wday
    self.hour   = self.started_at.hour
    self.week   = self.date.cweek
    self.day    = self.started_at.day
    self.month  = self.started_at.month
    self.year   = self.started_at.year
    self.timezone = row[:timezone] if row[:timezone]
  end

  def create_campaign_association(row)
    return unless row[:campaign_name]
    self.campaign = Campaign.find_by_code(row[:campaign_name])
    self.campaign_name = self.campaign.name
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
    session.save_time_metrics(row)
    session.create_campaign_association(row)
    session.property ? session : nil
  end

  def update_event_count
    self.event_count = self.events.count
    self.page_views = self.events.count(:conditions => Event::PAGE_VIEW)
    self.impressions = self.events.count(:conditions => Event::IMPRESSIONS)
  end
  
  def update_local_hour
    self.local_hour = (self.started_at + self.timezone.minutes).hour if self.timezone
  end    
  
  def update_session_time
    self.duration = (self.ended_at - self.started_at).to_i
  end

  def update_traffic_source
    if self.referrer_host && self.account && source = TrafficSource.find_from_referrer(self.referrer_host, self.account)
      self.referrer_category = source.source_type
    end
  end
end
