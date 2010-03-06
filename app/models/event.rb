class Event < ActiveRecord::Base
  skip_time_zone_conversion_for_attributes = :tracked_at, :log_tracked_at
  belongs_to        :session
  belongs_to        :redirect
  before_save       :update_label
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
  
  def self.create_from_row(session, row)
    return nil if !session || unknown_event?(row) || duplicate_event?(session, row)
    @logger ||= row[:logger] || Rails.logger
    
    event = new_from_row(row)
    if previous_event = session.events.find(:first, :conditions => 'sequence IS NOT NULL', :order => 'sequence DESC')
      previous_event.exit_page = false
      previous_event.duration = (event.tracked_at - previous_event.tracked_at).to_i
      event.entry_page = false
      previous_event.save!
    else
      event.entry_page = true
    end
    event.session = session
    event.exit_page = true
    session.ended_at = event.tracked_at
    event
  end
 
  def url=(uri)
    parsed_uri = URI.parse(uri) rescue nil
    if parsed_uri
      path = parsed_uri.path
      if path.blank? 
        path = '/'
      else
        path = path.sub("\/#{self.index_page}\Z", '') unless self.index_page.blank?
      end
      super URI.unescape(path)
    else
      super(URI.unescape(uri)) unless uri.blank?
    end
  end

  def pageview?
    self.category == PAGE_CATEGORY && self.action == VIEW_ACTION
  end
  
  def self.email_opening?(row)
    row[:category] == EMAIL_CATEGORY && row[:action] == OPEN_ACTION
  end

  def email_opening?
    self.category == EMAIL_CATEGORY && self.action == OPEN_ACTION
  end
    
private
  def self.duplicate_event?(session, row)
    # If no view then it's an open email or a redirect, which is OK
    return false if !row[:view]
    if session.events.find_by_sequence(row[:view])
      logger.error "[Event] Duplicate event found for sequence #{row[:view]}"
      logger.error row.inspect
      true
    else
      false
    end
  end
      
  def self.unknown_event?(row)
    if unknown = row[:view].blank? && !email_opening?(row) && !redirect?(row)
      logger.error "[Event] Unknown event detected (no view sequence number; not an email open event; not a redirect)"
    end
    unknown
  end
    
  def self.redirect?(row)
    row[:redirect]
  end

  def self.new_from_row(attrs)
    event = new
    event.attributes.each do |k, v|
      event.send("#{k.to_s}=",  attrs[k.to_sym])
    end
    event.sequence = attrs[:view]
    
    # All actions, include page views, are events
    # If no event data is provided then it's a pageview
    # event
    unless event.category && event.action
      event.category  = PAGE_CATEGORY
      event.action    = VIEW_ACTION
      event.label     = event.page_title
    end
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
end
