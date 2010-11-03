class Event < ActiveRecord::Base
  skip_time_zone_conversion_for_attributes = :tracked_at
  normalize_attributes :entry_page, :exit_page, :with => :true_or_null
  
  belongs_to        :session
  belongs_to        :redirect
  
  before_save       :update_label
  before_save       :check_page_view
  before_save       :apply_index_path_filter
  after_save        :update_video_maxplay
  
  attr_accessor     :logger
  
  PAGE_CATEGORY   = "page"
  VIEW_ACTION     = "view"
  
  VIDEO_CATEGORY  = 'video'
  VIDEO_MAXPLAY   = 'max_play'
  VIDEO_PLAY      = 'play'
  VIDEO_PAUSE     = 'pause'
  VIDEO_END       = 'end'
  VIDEO_EXIT      = 'exit'
  
  EMAIL_CATEGORY  = 'email'
  OPEN_ACTION     = 'open'
  
  AD_CATEGORY     = 'ad'
  SERVE_ACTION    = 'serve'
  
  EMAIL_OPENING   = "events.category = '#{EMAIL_CATEGORY}' AND events.action = '#{OPEN_ACTION}'"
  VIDEO_VIEW      = "events.category = '#{VIDEO_CATEGORY}' and events.action = '#{VIDEO_PLAY}'"
  VIDEO_MAXVIEW   = "events.category = '#{VIDEO_CATEGORY}' AND events.action = '#{VIDEO_MAXPLAY}'"
  AD_VIEW         = "events.category = '#{AD_CATEGORY}' AND events.action = '#{SERVE_ACTION}'"
  PAGE_VIEW       = "category = '#{PAGE_CATEGORY}' AND action = '#{VIEW_ACTION}' AND url IS NOT NULL"
  IMPRESSIONS     = "(#{EMAIL_OPENING}) || (#{AD_VIEW})"
  
  named_scope :email_opening,
    :conditions => EMAIL_OPENING
    
  named_scope :for_contact, lambda { |contact_code|
    { :conditions => ['contact_code = ?', contact_code] }
  }
  
  def self.create_from(session, track)
    return nil if !session?(session) || unknown_event?(track) || duplicate_event?(session, track)
    
    event = new_from_track(session, track)
    if previous_event = session.events.find(:first, :conditions => 'sequence IS NOT NULL', :order => 'sequence DESC')
      previous_event.exit_page = nil
      previous_event.duration = (event.tracked_at - previous_event.tracked_at).to_i if !previous_event.duration || previous_event.duration == 0
      event.entry_page = nil
      previous_event.save!
    else
      event.entry_page = true
    end
    event.exit_page = true
    
    # If its an email open then force the end of session time
    # to match the duration of the opening (Session calculates
    # duration on save)
    if event.email_opening? && event.duration && !previous_event
      session.ended_at = session.started_at + event.duration.seconds
    else
      session.ended_at = track.tracked_at
    end
    
    # If this is an click through, then check if its the first
    # for this campaign and this contact - if so mark first_impression
    # in the session as true.
    if event.email_opening? && session.campaign && event.contact_code && !session.first_click
      session.first_impression = !session.campaign.sessions.first_impression_for_contact(contact_code).first
    end
    
    # If this is an page view, then check if its the first
    # for this campaign and this contact - if so mark first_click
    # in the session as true.
    if event.click_through? && session.campaign && event.contact_code && !session.first_click
      session.first_click = !session.campaign.sessions.first_click_through_for_contact(contact_code).first
    end
        
    session.save!
    event.save!
    event
  end

  def url=(uri)
    parsed_uri = URI.parse(uri) rescue nil
    if parsed_uri
      path = parsed_uri.path.blank? ? '/' : parsed_uri.path
      super URI.unescape(path)
    else
      super(URI.unescape(uri)) unless uri.blank?
    end
  end
  
  # If configured in the web property, delete the matched
  # regexp. Helpful if page titles have a common prefix
  def page_title=(title)
    title_prefix = self.session.property.title_prefix if self.session.property
    title_prefix.blank? ? super : super(title.sub(Regexp.new(title_prefix),''))
  end

  def pageview?
    self.category == PAGE_CATEGORY && self.action == VIEW_ACTION
  end
  
  def self.email_opening?(track)
    track.category == EMAIL_CATEGORY && track.action == OPEN_ACTION
  end

  def email_opening?
    self.category == EMAIL_CATEGORY && self.action == OPEN_ACTION
  end
  
  def click_through?
    self.session.campaign_medium == EMAIL_CATEGORY  
  end
    
private
  def self.duplicate_event?(session, track)
    # If no view then it's an open email or a redirect, which is OK
    return false if !track.view
    if session.events.find_by_sequence(track.view)
      logger.error "[Event] Duplicate event found for session #{track.session} and sequence #{track.view}"
      logger.debug track.inspect
      true
    else
      false
    end
  end
      
  def self.unknown_event?(track)
    if unknown = track.view.blank? && !email_opening?(track) && !redirect?(track)
      logger.error "[Event] Unknown event detected (no view sequence number; not an email open event; not a redirect)"
      logger.error "[Event] Tracking data:"
      logger.error track.inspect
    end
    unknown
  end
  
  def self.session?(session)
    logger.error "[Event] Session is nil, no event can be created." unless session
    session
  end    
    
  def self.redirect?(track)
    track.redirect?
  end

  def self.new_from_track(session, track)
    event = new
    event.logger = Trackster::Logger
    event.session = session
    event.attributes.each do |k, v|
      event.send("#{k}=", track[k.to_sym]) if Analytics::TrackEvent.has_attribute?(k)
    end
    event.sequence = track.view
    
    # All actions, include page views, are events
    # If no event data is provided then it's a pageview
    # event
    unless event.category && event.action
      event.category  = PAGE_CATEGORY
      event.action    = VIEW_ACTION
      event.label     = event.page_title
    end
    
    # For email openings we treat the request_time as the amount of
    # time in seconds that the email was being read.  Relies upon
    # streaming the tracking image.
    event.duration = track.request_time.round if event.email_opening? && valid_request_time?(track)
    
    event
  end
  
  def update_video_maxplay
    return unless self.category == VIDEO_CATEGORY && (self.action == VIDEO_PAUSE || self.action == VIDEO_END || self.action == VIDEO_EXIT)
    maxplay_event = find_video_maxplay_event(self) || create_video_maxplay_from(self)
    if self.value && (maxplay_event.value.nil? || self.value > maxplay_event.value)
      maxplay_event.value = self.value 
      maxplay_event.save!
    end
    self
  end
  
  def find_video_maxplay_event(event)
    self.class.find(:first, :conditions => ['session_id = ? AND category = ? AND action = ? AND label = ?', event.session_id, VIDEO_CATEGORY, VIDEO_MAXPLAY, event.label])
  end
  
  def create_video_maxplay_from(event)
    self.class.new(
      :session_id => event.session_id, :category => VIDEO_CATEGORY, 
      :action => VIDEO_MAXPLAY, :label => event.label,
      :entry_page => false, :exit_page => false)
  end
  
  # Try to make sure we have reasonable labels even if none is supplied
  def update_label
    if self.email_opening? && self.label.blank?
      self.label = self.session.campaign_name unless self.session.campaign_name.blank?
    elsif self.pageview? && self.label.blank?
      self.label = self.page_title || self.url
    end
  end
  
  def apply_index_path_filter
    return unless filter = self.session.property.try(:index_page)
    self.url = self.url.sub(/\/#{filter}\Z/,'/') unless self.url.blank? || filter.blank?
  end
  
  def check_page_view
    if self.category == PAGE_CATEGORY && self.action == VIEW_ACTION
      self.page_view = true
    end
  end
  
  def self.logger
    Trackster::Logger
  end
  
  # We ignore 0 request time because that means its old style 
  # tracking with non-streaming GIF.
  def self.valid_request_time?(track)
    track.request_time && track.request_time > 0 
  end
end
