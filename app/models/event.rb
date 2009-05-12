class Event < ActiveRecord::Base
  belongs_to        :session
  belongs_to        :track
  after_save        :update_video_play_time
  
  PAGE_CATEGORY = "page"
  VIEW_ACTION = "view"
  VIDEO_CATEGORY = 'video'
  VIDEO_MAXPLAY = 'max play'
  
  def self.create_from_row(session, row)
    return nil if !session || row[:view].blank?
    if session.events.find_by_sequence(row[:view])
      Rails.logger.error "Duplicate event found"
      Rails.logger.error row.inspect
      return nil
    end
    
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
  
  def pageview?
    self.category == PAGE_CATEGORY && self.action == VIEW_ACTION
  end
  
private
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
  
  def update_video_play_time
    return unless video_max_play_event?
    max_play_event = Event.find_by_session_id_and_category_and_action(self.session_id, VIDEO_CATEGORY, VIDEO_MAXPLAY) || Event.new
    if max_play_event.new_record?
      max_play_event.attributes = self.attributes
      max_play_event.value = 0
      max_play_event.category = VIDEO_CATEGORY
      max_play_event.action = VIDEO_MAXPLAY
    end
    if self.value && self.value >= max_play_event.value
      max_play_event.value = self.value
      max_play_event.tracked_at = self.tracked_at
      max_play_event.save!      
    end
  end 
    
  def video_max_play_event?
    self.category == VIDEO_CATEGORY && (action == 'pause' || action == 'end')
  end
end
