class EventObserver < ActiveRecord::Observer
  observe :event
  
  def after_create(record)
    return unless record.contact_code
    History.record_tracking_event(record)
  end

end
