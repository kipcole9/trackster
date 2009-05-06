class Session < ActiveRecord::Base
  has_many      :events
  belongs_to    :property
  before_save   :update_session_time
  before_save   :update_event_count
  attr_accessor :referrer
  
  def self.find_or_create_from_track(row)
    if row.visitor && row.visit && row.session
      session = find_by_visitor_and_visit_and_session(row.visitor, row.visit, row.session)
    end
    session = new_from_row(row) unless session
  end

private
  def self.new_from_row(row)
    session = new
    attrs = row.attributes
    
    # Copy the common attributes from the tracker row
    session.attributes.each do |k, v|
      session.send("#{k.to_s}=",  attrs[k])
    end
    
    # Note session relevant data.  Session must be
    # tied to a site else it's a bogus sesssion
    session.started_at  = row.tracked_at
    session.referrer    = row.referrer
    session.ended_at    = session.started_at
    session.property    = row.property
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
