class Event < ActiveRecord::Base
  belongs_to        :session
  belongs_to        :track
  
  PAGE_CATEGORY   = "page"
  VIEW_ACTION     = "view"
  VIDEO_CATEGORY  = 'video'
  VIDEO_MAXPLAY   = 'max play'
  EMAIL_CATEGORY  = 'email'
  OPEN_ACTION     = 'open'
  
  def self.create_from_row(session, row)
    return nil if !session || unknown_event?(row) || duplicate_event?(session, row)
    event = new_from_row(row)
    if previous_event = session.events.last
      if event.pageview?
        previous_event.value = (event.tracked_at - previous_event.tracked_at).to_i
      end
      previous_event.exit_page = false
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
  
  def referrer=(r)
    return if r.blank? || r == '-'
    super
  end
  
  def url=(uri)
    super(URI.unescape(uri)) unless uri.blank?
  end
  
  def pageview?
    self.category == PAGE_CATEGORY && self.action == VIEW_ACTION
  end
  
private
  def self.duplicate_event?(session, row)
    # If no view then it's an open email, which is OK
    return false if !row[:view]
    if session.events.find_by_sequence(row[:view])
      Rails.logger.error "Duplicate event found"
      Rails.logger.error row.inspect
      true
    else
      false
    end
  end
      
  def self.unknown_event?(row)
    row[:view].blank? && !email_opening_event?(row)
  end
    
  def self.email_opening_event?(row)
    row[:category] == EMAIL_CATEGORY && row[:action] == OPEN_ACTION
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
      event.category = PAGE_CATEGORY
      event.action = VIEW_ACTION
      event.label = event.page_title
    end
    event
  end

end
