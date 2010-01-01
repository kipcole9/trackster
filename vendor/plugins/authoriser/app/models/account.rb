class Account < ActiveRecord::Base
  unloadable
  include         Analytics::Model
  authenticates_many  :user_sessions
  
  has_many        :properties
  has_many        :tracks
  has_many        :traffic_sources
  has_many        :sessions
  has_many        :campaigns
  has_many        :redirects
  has_many        :account_users
  has_many        :users, :through => :account_users
  has_many        :contacts
  has_many        :teams
  
  has_many        :clients, :class_name => "Account", :foreign_key => :agent_id
  belongs_to      :agent,   :class_name => "Account", :foreign_key => :agent_id
  
  validates_presence_of     :name
  validates_uniqueness_of   :name  
  validates_length_of       :name,            :within => 3..40
  validates_format_of       :name,            :with => /\A[a-zA-Z0-9-]+\Z/
  validates_exclusion_of    :name,            :in => %w( support blog www billing help api video map )
  
  validates_format_of       :email_from,      :with => User::EMAIL_REGEX, :allow_blank => true
  validates_format_of       :email_reply_to,  :with => User::EMAIL_REGEX, :allow_blank => true
  
  #composed_of               :calendar, :class_name => "CalendarProxy",
  #                          :mapping  => CalendarProxy::COMPOSED_OF_MAPPING
    
  before_create   :create_tracker_code
  before_save     :ensure_account_kind
  
  has_attached_file :logo, :styles => { :banner => "400x23" }
  
  ADMIN_ACCOUNT     = "Admin"
  ADMIN_DESCRIPTION = "Administration Account"
  
  CLIENT_ACCOUNT    = 'client'
  AGENCY_ACCOUNT    = 'agency'
  SPONSOR_ACCOUNT   = 'sponsor'

  def self.ensure_admin_exists
    unless admin = find_by_name(ADMIN_ACCOUNT)
      admin = create!(:name => ADMIN_ACCOUNT, :description => ADMIN_DESCRIPTION)
    end
  end
  
  def self.admin_account
    find_by_name(ADMIN_ACCOUNT)
  end
  
  # Only used to migrate from old property-centric system
  # delete after that
  def self.ensure_tracker_code_exists
    all.each do |a|
      a.send :create_tracker_code if a.tracker.blank?
      a.name = a.name.gsub(' ','-')
      a.save!
    end
  end
  
  def client_account?
    self.kind == CLIENT_ACCOUNT
  end
  
  def agency_account?
    self.kind == AGENCY_ACCOUNT
  end
  
  def sponsor_account?
    self.kind == SPONSOR_ACCOUNT
  end
  
private
  def create_tracker_code
    token = nil
    until token && !self.class.find_by_tracker(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.tracker = token
  end
  
  def ensure_account_kind
    self.kind = CLIENT_ACCOUNT if self.kind.blank?
  end
end
