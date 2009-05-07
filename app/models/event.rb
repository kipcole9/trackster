class Event < ActiveRecord::Base
  belongs_to        :session
  belongs_to        :track
  
  PAGE_CATEGORY = "page"
  VIEW_ACTION = "view"
  
  def self.create_from_row(session, row)
    return nil if !session || row.view.blank?
    if session.events.find_by_sequence(row[:event])
      Rails.logger.error "Duplicate event found"
      Rails.logger.error row.inspect
      return nil
    end
    
    event = new_from_row(row.attributes)
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
    event.track = row
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
