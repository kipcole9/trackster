class Account < ActiveRecord::Base
  unloadable
  before_save             :create_ip_filter
  normalize_attributes    :name, :custom_domain, :ip_filter, :ip_filter_sql
  authenticates_many      :user_sessions
  
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
  has_many        :imports
  has_many        :history, :class_name => "History"
  has_many        :contents do
    def selection
      all.map{|c| [c.name, c.id]}
    end
  end  
  
  # Client/agent relationships.  An account can have many clients.  A client can have only 
  # one agent.  A client account cannot, itself, have client accounts.
  has_many        :clients, :class_name => "Account", :foreign_key => :agent_id
  belongs_to      :agent,   :class_name => "Account", :foreign_key => :agent_id
  
  validates_presence_of     :name
  validates_uniqueness_of   :name  
  validates_length_of       :name,            :within => 3..20
  validates_format_of       :name,            :with => /\A[a-zA-Z0-9-]+\Z/
  validates_exclusion_of    :name,            :in => %w( support blog www billing help api video map )

  validates_format_of       :custom_domain,   :with => Property::DOMAIN_REGEX, :allow_blank => true
  validates_uniqueness_of   :custom_domain,   :allow_nil => true
  
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

  def add_user(user, roles)
    self.account_users.create(:user => user, :roles => roles)
  end
  
  def user_exists?(email)
    self.users.find_by_email(email)
  end
  
  def client_account?
    @client_account ||= self.agent
  end
  
  def agency_account?
    @agency_account ||= self.clients.count > 0
  end
  
  ADMIN_USER  = 'admin'
  def self.admin
    find_by_name(ADMIN_USER)
  end
  
  def theme
    return attributes['theme'] unless attributes['theme'].blank?
    return agent.theme if client_account?
    nil
  end
  
  def self.current_account=(account)
    Thread.current[:current_account] = account
  end
  
  def self.current_account
    Thread.current[:current_account]
  end
  

private
  def create_tracker_code
    token = nil
    until token && !self.class.find_by_tracker(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.tracker = token
  end
  
  IP_V4       = "(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})"
  SINGLE_IPv4 = /\A#{IP_V4}\Z/
  IPv4_RANGE  = /\A#{IP_V4}-#{IP_V4}\Z/
  CIDR        = /\A(#{IP_V4}\/\d{1,2})\Z/
  
  def create_ip_filter
    if self.ip_filter.blank?
      self.ip_filter_sql = nil
      return
    end
    ip_address = nil
    sql_filter = ip_filter.split(',').inject([]) do |clauses, ip|
      ip_address = ip.strip
      if ip_address =~ SINGLE_IPv4
        # IPv4 address
        clauses << "ip_integer <> #{IP::Address::Util.string_to_ip($1).pack}"
      elsif ip_address =~ IPv4_RANGE
        clauses << "ip_integer < #{IP::Address::Util.string_to_ip($1).pack} AND ip_integer > #{IP::Address::Util.string_to_ip($2).pack}"
      elsif ip_address =~ CIDR
        # CIDR format
        cidr_address = IP::CIDR.new($1)
        clauses << "ip_integer < #{cidr_address.first_ip.pack} AND ip_integer > #{cidr_address.last_ip.pack}"
      elsif ip_address =~ Property::DOMAIN_REGEX
        # Its a hostname?
        host_address = IP::Address::Util.string_to_ip(Resolv.getaddress(ip_address).to_s).pack
        clauses << "ip_integer <> #{host_address}"
      else
        raise ArgumentError
      end
      clauses
    end
    self.ip_filter_sql = sql_filter.join(' AND ')
  rescue
    errors.add(:ip_filter, I18n.t('account.invalid_ip_address', :address => ip_address))
  end

end
