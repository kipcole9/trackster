class Property < ActiveRecord::Base
  include     Analytics::Model
  has_many    :campaigns
  has_many    :sessions
  has_many    :tracks
  has_many    :redirects
  belongs_to  :account

  before_save         :update_host_column

  has_attached_file :thumb, :styles => { :thumb => "100x100" }
  
  named_scope :user, lambda {|user|
    {:conditions => {:id => user.properties.map(&:id)} }
  }
  
  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or url like ?', search, search ]}
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
  
  def get_absolute_url(url)
    if URI.parse(url).scheme
      url
    else
      [self.url, url].join('')
    end
  end
  
private
  
  def update_host_column
    begin
      self.host = URI.parse(self.url).host
    rescue
      Rails.logger.error "[property] Could not parse property url to create host: '#{self.url}'"
    end
  end
end
