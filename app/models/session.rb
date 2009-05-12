class Session < ActiveRecord::Base
  has_many      :events
  belongs_to    :property
  before_save   :update_session_time
  before_save   :update_event_count
  attr_accessor :referrer  
  
  def self.find_or_create_from_track(row)
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

private
  def self.new_from_row(row)
    session = new
    
    # Copy the common attributes from the tracker row
    session.attributes.each do |k, v|
      session.send("#{k.to_s}=",  row[k.to_sym])
    end
    session.started_at  = row[:tracked_at]
    session.referrer    = row[:referrer]
    session.ended_at    = session.started_at 
    
    # See if there was a previous session
    if session.visit && session.visit > 1 && previous_visit = find_by_visitor_and_visit(session.visitor, session.visit - 1)
      session.previous_visit_at = previous_visit.started_at
    end
    
    # Note session relevant data.  Session must be
    # tied to a site else it's a bogus sesssion
    session.property = Property.find_by_tracker(row[:property_code])
    session.property ? session : nil
  end
  
  def update_event_count
    self.event_count = self.events.count
    self.page_views = self.events.count(:conditions => ["category = 'page' AND action = 'view'"])
  end
  
  def update_session_time
    self.duration = (self.ended_at - self.started_at).to_i
  end


end
