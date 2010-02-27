class Account < ActiveRecord::Base
  unloadable if Rails.env == 'development'
  include         Analytics::Model
  
  ADMIN_USER            = 'admin'
  CUSTOM_DOMAIN_REGEX   = /\A#{User::DOMAIN_HEAD_REGEX}#{User::DOMAIN_TLD_REGEX}\z/i
  
  authenticates_many  :user_sessions
  has_many        :account_users
  has_many        :users, :through => :account_users
  has_many        :properties
  has_many        :tracks
  has_many        :traffic_sources
  has_many        :sessions
  has_many        :campaigns
  has_many        :redirects
  has_many        :contacts
  has_many        :people
  has_many        :organizations
  has_many        :teams
  
  # Client/agent relationships.  An account can have many clients.  A client can have only 
  # one agent.  A client account cannot, itself, have client accounts.
  has_many        :clients, :class_name => "Account", :foreign_key => :agent_id
  belongs_to      :agent,   :class_name => "Account", :foreign_key => :agent_id
  
  validates_presence_of     :name
  validates_uniqueness_of   :name  
  validates_length_of       :name,            :within => 3..40
  validates_format_of       :name,            :with => /\A[a-zA-Z0-9-]+\Z/
  validates_exclusion_of    :name,            :in => %w( support blog www billing help api video map )

  validates_format_of       :custom_domain,   :with => CUSTOM_DOMAIN_REGEX, :allow_blank => true
  validates_length_of       :custom_domain,   :within => 5..100
  validates_uniqueness_of   :custom_domain
  
  validates_format_of       :email_from,      :with => User::EMAIL_REGEX, :allow_blank => true
  validates_format_of       :email_reply_to,  :with => User::EMAIL_REGEX, :allow_blank => true
  
  #composed_of               :calendar, :class_name => "CalendarProxy",
  #                          :mapping  => CalendarProxy::COMPOSED_OF_MAPPING
    
  before_create             :create_tracker_code
  
  has_attached_file         :logo, :styles => { :banner => "400x23" }

  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or description like ?', search, search ]}
  }

  def client_account?
    @client_account ||= self.agent
  end
  
  def agency_account?
    @agency_account ||= self.clients.count > 0
  end
  
  def self.admin
    find_by_name(ADMIN_USER)
  end

private
  def create_tracker_code
    token = nil
    until token && !self.class.find_by_tracker(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.tracker = token
  end

end
