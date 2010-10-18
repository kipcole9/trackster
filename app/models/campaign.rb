class Campaign < ActiveRecord::Base  
  belongs_to    :account
  has_many      :sessions
  has_many      :tracks
  belongs_to    :email_content, :class_name => 'Content', :foreign_key => :content_id
  
  before_create  :create_campaign_code

  validates_associated      :account
  validates_presence_of     :account_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..150
  validates_uniqueness_of   :name,    :scope => :account_id
  
  validates_numericality_of :cost,          :allow_nil => true  
  validates_numericality_of :bounces,       :allow_nil => true
  validates_numericality_of :unsubscribes,  :allow_nil => true
  validates_numericality_of :distribution,  :allow_nil => true
  
  normalize_attributes      :name, :description
  
  default_scope :order => 'created_at DESC'
  
  # Supports user_scope method
  named_scope :user, lambda {|user|
    {:conditions => {:property_id => user.properties.map(&:id)} }
  }

  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or description like ?', search, search ]}
  }

  def email=(c)
    self.content_id = c
    self.content_id_will_change!
  end
  
  def email
    self.email_content.id rescue nil
  end
  
  def content_code
    self.email_content && self.email_content.code
  end
  
  def refers_to
    self
  end
  
  def relink_email_html(params = {})
    return nil if (email_content = self.email_content.content).blank?
    Trackster::Translinker::HtmlEmail.translink(email_content, 
      :campaign       => self, 
      :base_url       => self.email_content.base_url,
      :image_location => params[:image_location]
    )
  end
  
private
  def create_campaign_code
    token = nil
    until token && !self.class.find_by_code(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.code = token
    self.medium = 'email'
  end
  

end
