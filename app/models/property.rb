class Property < ActiveRecord::Base
  has_many    :campaigns
  has_many    :sessions
  has_many    :tracks
  has_many    :redirects
  has_many    :property_users
  has_many    :users, :through => :property_users
  
  belongs_to  :account

  before_create :create_tracker_code 
  
  named_scope :user, lambda {|user|
    {:conditions => {:id => user.properties.map(&:id)} }
  }
  
  validates_associated      :account
  validates_presence_of     :account_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..40
  validates_uniqueness_of   :name,    :scope => :account_id
  
  validates_presence_of     :url
  validates_length_of       :url,     :within => 5..100
  validates_uniqueness_of   :url
  validates_format_of       :url,     :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

  validates_format_of       :search_parameter, :with => /[a-z0-9]+/i, :allow_nil => true

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

  def create_tracker_code
    token = nil
    until token && !self.class.find_by_tracker(token)
      token = "tks-#{ActiveSupport::SecureRandom.hex(3)}-1"
    end
    self.tracker = token
  end
end
