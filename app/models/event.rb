class Event < ActiveRecord::Base
  belongs_to        :session
  belongs_to        :track
  
  PAGE_CATEGORY = "page"
  VIEW_ACTION = "view"
  
  def self.create_from_row(session, row)
    return nil if !session || row.view.blank?
    Rails.logger.error "Duplicate event found" if session.events.find_by_sequence(row[:event])
    event = new_from_row(row.attributes)
    if previous_event = session.events.last
      previous_event.duration = (event.evented_at - previous_event.evented_at).to_i
      previous_event.exit_page = false
      event.entry_page = false
      previous_event.save!
    else
      event.entry_page = true
    end
    event.track = row
    event.session = session
    event.exit_page = true
    session.ended_at = event.tracked_at
    event
  end
  
private
  def self.new_from_row(attrs)
    event = new
    event.attributes.each do |k, v|
      event.send("#{k.to_s}=",  attrs[k])
    end
    event.sequence = attrs['view']
    
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
