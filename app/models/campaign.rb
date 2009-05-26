class Campaign < ActiveRecord::Base
  belongs_to    :property
  has_many      :sessions
  
  before_create  :create_campaign_code
   
  validates_associated    :property
  validates_presence_of   :property_id

  validates_numericality_of :cost,          :allow_nil => true  
  validates_numericality_of :bounces,       :allow_nil => true
  validates_numericality_of :unsubscribes,  :allow_nil => true
  validates_numericality_of :distribution,  :allow_nil => true
  
  default_scope :order => 'created_at DESC'
  
  named_scope   :user, lambda {|user|
    {:conditions => {:property_id => user.properties.map(&:id)} }
  }
  
  def impressions
    sessions.count(:conditions => Event::EMAIL_OPENINGS, :joins => :events)
  end
  
  def first_impression
    impression(:first)
  end
  
  def last_impression
    impression(:last)
  end
  
  def clicks_through
    sessions.count(:conditions => "campaign_medium = '#{Session::EMAIL_CLICK}'", :joins => :events)
  end
  
private
  def impression(first_or_last = :last)
    order = first_or_last == :first ? 'ASC' : 'DESC'
    self.sessions.find(:first, :conditions => Event::EMAIL_OPENINGS, :order => "events.tracked_at #{order}", :joins => :events)
  end
  
  def create_campaign_code
    token = nil
    until token && !self.class.find_by_code(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.code = token
  end
end
