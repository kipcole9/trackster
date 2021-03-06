class Session < ActiveRecord::Base
  skip_time_zone_conversion_for_attributes = :started_at, :ended_at
  normalize_attributes  :campaign_medium, :campaign_content, :campaign_source, :campaign_name
  normalize_attributes  :referrer, :flash_version, :forwarded_for, :with => :log_entry
  normalize_attribute   :country, :with => :upcase
  normalize_attributes  :first_impression, :first_click, :with => :true_or_null
  
  acts_as_taggable_on :tags
  belongs_to    :property
  belongs_to    :account
  belongs_to    :contact
  belongs_to    :campaign
  belongs_to    :content
  has_many      :events, :dependent => :destroy do
    def create_from(track)
      event = Event.create_from(proxy_owner, track)
      proxy_owner.update_viewcount!
      event
    end
  end
  
  before_create :save_time_metrics
  before_create :update_traffic_source
  before_create :update_ip_integer
  before_save   :update_session_time
  before_save   :update_event_count
  
  attr_accessor   :logger
  
  named_scope :first_impression_for_contact, lambda { |contact_code|
    {:conditions => ['contact_code = ? and first_impression = 1', contact_code],
      :limit => 1}
  }

  named_scope :first_click_through_for_contact, lambda { |contact_code|
    {:conditions => ['contact_code = ? and first_click = 1', contact_code],
      :limit => 1}
  }
  
  def self.find_or_create_from(track)
    raise ArgumentError, "Tracked_at is nil" unless track.tracked_at
    session = find_by_visitor_and_visit_and_session(track.visitor, track.visit, track.session) if have_visitor?(track)
    session ||= new_from_track(track)
  end
  
  # To trigger before_save viewcount updating
  def update_viewcount!
    self.save!
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

  def create_content_association(track)
    return nil if track.campaign_content.blank?
    unless self.content = self.account.contents.find_by_code(track.campaign_content)
      logger.error "[Session] Content '#{track.host}' is not associated with account '#{self.account.name}'."
    end
    self.content
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
      session.create_content_association(track)
    else
      logger.error "[Session] Account '#{track.account_code}' is not known. Session will not be created."
      return nil
    end
    return nil if track.host && !session.property
    session.save!
    session
  end
  
  def save_time_metrics
    return unless self.timezone
    local_time = self.started_at + self.timezone.minutes
    self.date            = local_time.to_date
    self.day_of_week     = local_time.wday
    self.hour            = local_time.hour
    self.week            = local_time.to_date.cweek
    self.day_of_month    = local_time.day
    self.month           = local_time.month
    self.year            = local_time.year
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
  
  def update_ip_integer
    return if self.ip_address.blank?
    begin
      self.ip_integer = IP::Address::Util.string_to_ip(self.ip_address).pack 
    rescue
      logger.warn "[Session] Invalid IP Address detected: '#{self.ip_address}'"
    end
  end

  def self.have_visitor?(track)
    track.visitor && track.visit && track.session
  end
  
  def logger
    Trackster::Logger
  end
end
