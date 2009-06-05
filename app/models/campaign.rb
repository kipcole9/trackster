class Campaign < ActiveRecord::Base
  belongs_to    :property
  has_many      :sessions
  has_many      :tracks
  
  before_create  :create_campaign_code
   
  validates_associated    :property
  validates_presence_of   :property_id

  validates_numericality_of :cost,          :allow_nil => true  
  validates_numericality_of :bounces,       :allow_nil => true
  validates_numericality_of :unsubscribes,  :allow_nil => true
  validates_numericality_of :distribution,  :allow_nil => true
  
  default_scope :order => 'created_at DESC'
  
  # Supports user_scope method
  named_scope :user, lambda {|user|
    {:conditions => {:property_id => user.properties.map(&:id)} }
  }
  
  def landing_page_html=(html)
    html.class.name == "Tempfile" ? super(html.read) : super(html)
  end

  def email_html=(html)
    html.class.name == "Tempfile" ? super(html.read) : super(html)
  end
  
private
  def create_campaign_code
    token = nil
    until token && !self.class.find_by_code(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.code = token
  end
end
