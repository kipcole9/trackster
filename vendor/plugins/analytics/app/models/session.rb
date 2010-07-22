class Session < ActiveRecord::Base
  skip_time_zone_conversion_for_attributes = :started_at, :ended_at
  acts_as_taggable_on :tags
  belongs_to    :property
  belongs_to    :account
  belongs_to    :campaign
  has_many      :events, :dependent => :destroy do
    def create_from(track)
      event = Event.create_from(proxy_owner, track)
      proxy_owner.update_viewcount!
      event
    end
  end
  
  before_create :save_time_metrics
  before_create :update_traffic_source
  before_save   :update_session_time
  before_save   :update_event_count
  
  attr_accessor   :logger

  def self.find_or_create_from(track)
    raise ArgumentError, "Tracked_at is nil" unless track.tracked_at
    session = find_by_visitor_and_visit_and_session(track.visitor, track.visit, track.session) if have_visitor?(track)
    session ||= new_from_track(track)
  end
  
  # To trigger before_save viewcount updating
  def update_viewcount!
    self.save!
  end
  
  def referrer=(r)
    super unless is_empty?(r) 
  end
  
  def flash_version=(r)
    super unless is_empty?(r)
  end

  def forwarded_for=(r)
    super unless is_empty?(r)
  end
  
  def country=(c)
    super(c.upcase) unless c.blank?
  end

  # Language is the first part of the locale.  
  # ie. from en-US the language is 'en'.
  def language=(l)
    return if l.blank?
    language_parts = l.gsub('_','-').split('-')
    super(language_parts.first.downcase)
  end
  
  # Dialect only applicable if it is multiple part locale
  # ie. 'en-US' is OK, 'en' is not (that's just the language part)
  def dialect=(d)
    super(d.downcase) unless d.blank? || (d !~ /-/)
  end
  
  def browser=(b)
    (b && b == 'IE') ? super('Internet Explorer') : super
  end

  def create_campaign_association(track)
    return nil if track.campaign_name.blank?
    if self.campaign = self.account.campaigns.find_by_code(track.campaign_name)
      self.campaign_name = self.campaign.name
    else
      logger.error "[Session] No campaign '#{track.campaign_name}' exists.  Campaign will not be associated."
    end
    self.campaign
  end

  def create_property_association(track)
    return nil if track.host.blank?
    unless self.property = self.account.properties.find_by_host(track.host)
      logger.error "[Session] Host '#{track.host}' is not associated with account '#{self.account.name}'."
    end
    self.property
  end

private
  def self.new_from_track(track)
    session = new
    session.logger = Trackster::Logger

    # Copy the common attributes from the tracker
    session.attributes.each do |k, v|
      session.send("#{k}=",  track[k.to_sym]) if Analytics::TrackEvent.has_attribute?(k)
    end
    session.tag_list    = track.tags if track.tags
    session.started_at  = track.tracked_at
    session.ended_at    = session.started_at
    
    # See if there was a previous session. By keeping track of a previous visit we can
    # quickly detect if this is a new visitor or not, and we can also detect if this
    # is a repeat visitor for a give date range
    if session.visit && session.visit > 1 && previous_visit = find_by_visitor_and_visit(session.visitor, session.visit - 1)
      session.previous_visit_at = previous_visit.started_at
    end
    
    # Note session relevant data.  Session must be
    # tied to an account else it's a bogus session
    # If a host is defined it must be hooked to that too or its bogus.
    if session.account = Account.find_by_tracker(track.account_code)
      session.create_campaign_association(track)
      session.create_property_association(track)
    else
      logger.error "[Session] Account '#{track.account_code}' is not known. Session will not be created."
      return nil
    end
    return nil if track.host && !session.property
    session.save!
    session
  end
  
  def save_time_metrics
    self.date            = self.started_at.to_date
    self.day_of_week     = self.started_at.wday
    self.hour            = self.started_at.hour
    self.week            = self.date.cweek
    self.day_of_month    = self.started_at.day
    self.month           = self.started_at.month
    self.year            = self.started_at.year
  end

  def update_event_count
    self.event_count  = self.events.count
    self.page_views   = self.events.count(:conditions => Event::PAGE_VIEW)
    self.impressions  = self.events.count(:conditions => Event::IMPRESSIONS)
  end

  def update_session_time
    self.duration = (self.ended_at - self.started_at).to_i
  end

  def update_traffic_source
    if source = TrafficSource.find_from_referrer(self.referrer_host, self.account)
      self.referrer_category = source.source_type
    end
  end
  
  def is_empty?(s)
    s.blank? || s == '-'
  end
  
  def self.have_visitor?(track)
    track.visitor && track.visit && track.session
  end
  
  def logger
    Trackster::Logger
  end
end
