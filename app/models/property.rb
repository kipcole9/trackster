class Property < ActiveRecord::Base
  include     Analytics::Model
  has_many    :campaigns
  has_many    :sessions
  has_many    :tracks
  has_many    :redirects
  has_many    :property_users
  has_many    :users, :through => :property_users
  belongs_to  :account

  before_create :create_tracker_code 

  has_attached_file :thumb, :styles => { :thumb => "100x100" }
  
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

  validates_format_of       :search_parameter, :with => /[a-z0-9]+/i, :allow_nil => true, :allow_blank => true

  def url=(val)
    super(val.sub(/\/\Z/,''))
  end
  
private

  def create_tracker_code
    token = nil
    until token && !self.class.find_by_tracker(token)
      token = "tks-#{ActiveSupport::SecureRandom.hex(3)}-1"
    end
    self.tracker = token
  end
end
