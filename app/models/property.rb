class Property < ActiveRecord::Base
  DOMAIN_HEAD_REGEX   = '(?:[A-Z0-9\-]+\.)+'.freeze
  DOMAIN_TLD_REGEX    = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|local|asia)'.freeze
  DOMAIN_REGEX        = /\A#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i
  
  has_many    :campaigns
  has_many    :sessions
  has_many    :tracks
  has_many    :redirects
  belongs_to  :account

  has_attached_file :thumb, :styles => { :thumb => "100x100" }
  
  normalize_attributes    :name, :description
  
  named_scope :user, lambda {|user|
    {:conditions => {:id => user.properties.map(&:id)} }
  }
  
  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or host like ?', search, search ]}
  }
  
  validates_associated      :account
  validates_presence_of     :account_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..40
  validates_uniqueness_of   :name,    :scope => :account_id
  
  validates_presence_of     :host
  validates_length_of       :host,    :within => 5..100
  validates_uniqueness_of   :host,    :scope => :account_id
  validates_format_of       :host,    :with => DOMAIN_REGEX

  validates_format_of       :search_parameter, :with => /[a-z0-9]+/i, :allow_nil => true, :allow_blank => true

  def host=(val)
    super(val.sub(/\/\Z/,''))
  end
  
  def url
    "http://#{self.host}"
  end
  
  
end
