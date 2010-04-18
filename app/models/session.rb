class Session < ActiveRecord::Base
  skip_time_zone_conversion_for_attributes = :started_at, :ended_at
  acts_as_taggable_on :tags
  has_many      :events, :dependent => :destroy
  belongs_to    :property
  belongs_to    :account
  belongs_to    :campaign
  
  before_create :update_traffic_source
  before_save   :update_session_time
  before_save   :update_event_count
  
  attr_accessor  :logger
  
  EMAIL_CLICK   = 'email'
  
  def self.find_or_create_from_track(row)
    @logger ||= row[:logger] || Rails.logger
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
    super unless r.blank? || r == '-'
  end
  
  def flash_version=(r)
    super unless r.blank? || r == '-'
  end

  def forwared_for=(r)
    super unless r.blank? || r == '-'
  end
  
  def country=(c)
    super(c.upcase) unless c.blank?
  end

  # Language is the first part of the locale.  
  # ie. from en-US the language is 'en'.
  def language=(l)
    return if l.blank?
    language_parts = l.split('-')
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
  
  def save_time_metrics(row)
    self.date   = self.started_at.to_date
    self.day_of_week = self.started_at.wday
    self.hour   = self.started_at.hour
    self.week   = self.date.cweek
    self.day    = self.started_at.day
    self.month  = self.started_at.month
    self.year   = self.started_at.year
    self.timezone = row[:timezone] if row[:timezone]
  rescue NoMethodError => e
    logger.error "BAD BAD BAD BAD BAD"
    logger.error row.inspect
    logger.error self.inspect
    raise "Stop Here"
  end

  def create_campaign_association(row)
    return unless row[:campaign_name]
    @logger ||= row[:logger] || Rails.logger
        
    if self.campaign = self.account.campaigns.find_by_code(row[:campaign_name])
      self.campaign_name = self.campaign.name
    else
      logger.error "[Session] No campaign '#{row[:campaign_name]}' exists.  Campaign will not be associated."
    end
  end
  
  def create_property_association(row)
    return if row[:host].blank?
    @logger ||= row[:logger] || Rails.logger
    
    unless self.property = self.account.properties.find_by_host(row[:host])
      logger.error "[Session] Host '#{row[:host]}' is not associated with account '#{self.account.name}'."
    end
  end
  
  def reverse_geocode
    return if ip_address.blank?
    geodata = IpAddress.reverse_geocode(self.ip_address)
    self.country      = geodata[:country]
    self.region       = geodata[:region]
    self.locality     = geodata[:locality]
    self.latitude     = geodata[:latitude]
    self.longitude    = geodata[:longitude]
    self.geocoded_at  = geodata[:geocoded_at]
  end

private
  def self.new_from_row(row)
    session = new
    logger = row[:logger] || Rails.logger
    
    # Copy the common attributes from the tracker row
    session.attributes.each do |k, v|
      session.send("#{k.to_s}=",  row[k.to_sym])
    end
    session.tag_list    = row[:tags] if row[:tags]
    session.started_at  = row[:tracked_at]
    session.ended_at    = session.started_at
    
    # See if there was a previous session
    if session.visit && session.visit > 1 && previous_visit = find_by_visitor_and_visit(session.visitor, session.visit - 1)
      session.previous_visit_at = previous_visit.started_at
    end
    
    # Note session relevant data.  Session must be
    # tied to an account else it's a bogus session
    # If a host is defined it must be hooked to that too or its bogus.
    if session.account = Account.find_by_tracker(row[:account_code])
      session.save_time_metrics(row)
      session.create_campaign_association(row)
      session.create_property_association(row)
    else
      logger.error "[Session] Account '#{row[:account_code]}' is not known. Session will not be created."
    end
    return nil unless session.account
    return nil if     row[:host] && !session.property
    return session
  end

  def update_event_count
    self.event_count = self.events.count
    self.page_views = self.events.count(:conditions => Event::PAGE_VIEW)
    self.impressions = self.events.count(:conditions => Event::IMPRESSIONS)
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
