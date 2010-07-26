class User < ActiveRecord::Base
  #unloadable
  acts_as_authentic
  after_save                  :update_account_user
  before_validation           :update_password_if_required
  
  # disable_perishable_token_maintenance true
  # before_validation_on_create :reset_perishable_token

  LOGIN_REGEX               = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  # self.login_regex        = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
  # self.login_regex        = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  NAME_REGEX                = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  EMAIL_NAME_REGEX          = '[\w\.%\+\-]+'.freeze
  EMAIL_REGEX               = /\A#{EMAIL_NAME_REGEX}@#{Property::DOMAIN_HEAD_REGEX}#{Property::DOMAIN_TLD_REGEX}\z/i
  ADMIN_USER                = 'admin'
  
  has_attached_file         :photo, :styles => { :avatar => "50x50#" },
                            :convert_options => { :all => "-unsharp 0.3x0.3+3+0" }
  
  has_many                  :account_users, :autosave => true
  has_many                  :accounts, :through => :account_users

  validates_format_of       :given_name,      :with => NAME_REGEX, :allow_nil => true
  validates_length_of       :given_name,      :maximum => 100
  validates_format_of       :family_name,     :with => NAME_REGEX, :allow_nil => true
  validates_length_of       :family_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,           :within => 6..100 #r@a.wk
  validates_format_of       :email,           :with => EMAIL_REGEX
  
  # validates_uniqueness_of   :email => For some reason fails even when not true.
  # hand-craft instead.
  validate do |user|
    if User.first(:conditions => ["email = ? and id <> ?", user.email, user['id']])
      errors.add(:email, :taken)
    end
  end

  attr_accessible :email, :given_name, :family_name, :password, :password_confirmation,
                  :accounts, :remember_me?, :locale, :timezone, :roles, :photo, :state, :tags,
                  :current_password, :new_password, :new_password_confirmation
                  
  attr_accessor   :current_password, :new_password, :new_password_confirmation
  
  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['given_name like ? or family_name like ?', search, search ]}
  }
  
  def self.exists?(email)
    find_by_email(email)
  end
  
  def self.add_new(params)
    @user = User.new(params)
    @user.reset_password if @user.password.blank?
    @user.save_without_session_maintenance
    @user
  end
  
  def timezone=(zone)
    zone.blank? ? super(nil) : super
  end
  
  def new_password=(password)
    @new_password = password
  end
  
  def new_password_confirmation=(password)
    @new_password_confirmation = password
  end
  
  def active?
    state == 'active'
  end
  
  def inactive?
    state == 'passive'
  end

  def recently_activated?
    active? && login_count == 0
  end
  
  def has_no_credentials?
    self.crypted_password.blank? && self.openid_identifier.blank?
  end

  # User at activation
  def activate!(params)
    self.attributes = params[:user]
    self.state = 'active'
    self.activated_at = Time.now
    self.save
  end  
  
  def name
    @name ||= [self.given_name, self.family_name].compress.join(' ').strip
  end
  
  def self.admin_user
    User.find(:first, :conditions => "administrator = 1")
  end
  
  # Used by the login form
  def remember_me?
    1
  end
  
  # Used by the new_user form
  def roles=(roles)
    self.account_roles_mask = (roles & AccountUser::ROLES).map { |r| 2**AccountUser::ROLES.index(r) }.sum
  end
  
  def roles
    AccountUser::ROLES.reject { |r| ((self.account_roles_mask || 0) & 2**AccountUser::ROLES.index(r)).zero? }
  end
  
  def has_role?(role)
    roles.include?(role.to_s)
  end
  
  # Defines the tags that scope permitted access to
  # Sessions
  def tags=(tag_list)
    account_user.tags = tag_list unless tag_list.blank?
  end
  
  def tags
    account_user.tags
  end

  # Helper type methods
  def member_of?(account)
    accounts.find_by_name(account.name) || is_administrator?
  end
  
  def is_administrator?
    self.administrator?
  end
  alias :admin? :is_administrator?

  def self.current_user=(user)
    Thread.current[:current_user] = user
  end
  
  def self.current_user
    Thread.current[:current_user]
  end

protected
  def account_roles_mask=(roles)
    account_user.role_mask = roles
  end

  def account_roles_mask
    account_user.role_mask
  end

  # Our policy here is that a user on an Agency account passes down roles
  # to a Client account.  So if no role on the current account then check
  # on an Agency account if one.
  def account_user
    @account_user ||= user_on_account(Account.current_account) || user_on_agent_account(Account.current_account) ||
                      create_empty_account_user
  end  
  
  def user_on_account(account)
    account_users.find_by_account_id(account['id'])
  end
  
  def user_on_agent_account(account)
    return nil unless agent = account.agent
    agent.account_users.find_by_user_id(User.current_user['id'])
  end
  
  def create_empty_account_user
    account_users.build(:account => Account.current_account, :role_mask => 0)
  end

  def role_symbols
    roles.map(&:to_sym)
  end

private
  def update_account_user
    account_user.save if account_user
  end
  
  def update_password_if_required
    if !self.new_password.blank?
      if !self.current_password.blank?
        if self.valid_password?(self.current_password)
          self.password = self.new_password
          self.password_confirmation = self.new_password_confirmation
        else
          errors.add(:password, I18n.t('authorizer.could_not_change_password'))
        end
      else
        errors.add(:password, I18n.t('authorizer.current_password_empty'))
      end
    end
    self.errors.empty?
  end
  
end
