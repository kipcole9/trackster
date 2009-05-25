class Property < ActiveRecord::Base
  has_many    :campaigns
  has_many    :sessions
  has_many    :tracks
  has_many    :redirects
  has_many    :property_users
  has_many    :users, :through => :property_users
  
  belongs_to  :account

  after_create              :create_tracker_code 
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..40
  validates_uniqueness_of   :name,    :scope => :account_id
  
  validates_presence_of     :url
  validates_length_of       :url,     :within => 5..100
  validates_uniqueness_of   :url
  validates_format_of       :url,     :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

  validates_format_of       :search_parameter, :with => /[a-z0-9]+/i, :allow_nil => true
  
private
  def create_tracker_code
    sequence = "%05d" % self['id']
    self.tracker = "VIE-#{sequence}-1"
    self.save!
  end
end
