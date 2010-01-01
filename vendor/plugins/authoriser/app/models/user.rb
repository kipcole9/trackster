require 'digest/sha1'

class User < ActiveRecord::Base
  unloadable
  acts_as_authentic
  
  has_many                  :account_users, :autosave => true
  has_many                  :accounts, :through => :account_users
  after_save                :update_roles
  
  LOGIN_REGEX               = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  # self.login_regex        = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
  # self.login_regex        = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive

  NAME_REGEX                = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  EMAIL_NAME_REGEX          = '[\w\.%\+\-]+'.freeze
  DOMAIN_HEAD_REGEX         = '(?:[A-Z0-9\-]+\.)+'.freeze
  DOMAIN_TLD_REGEX          = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  EMAIL_REGEX               = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i

  ROLES                     = %w[admin agent sponsor user]
  
  has_attached_file         :photo, :styles => { :avatar => "50x50#" },
                            :convert_options => { :all => "-unsharp 0.3x0.3+3+0" }
  
  has_many                  :account_users
  has_many                  :accounts, :through => :account_users
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => LOGIN_REGEX

  validates_format_of       :given_name,     :with => NAME_REGEX, :allow_nil => true
  validates_length_of       :given_name,     :maximum => 100
  validates_format_of       :family_name,    :with => NAME_REGEX, :allow_nil => true
  validates_length_of       :family_name,    :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => EMAIL_REGEX

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :given_name, :family_name, :password, :password_confirmation, 
                  :account, :remember_me?, 
                  :locale, :timezone, :role, :photo, :name,
                  # Virtual attributes we use for changing password - make sure we don't interrupt the real data
                  :new_password, :new_password_confirmation
                  
  attr_accessor   :current_account

  def name
    [self.given_name, self.family_name].compress.join(' ').strip
  end
  
  def self.admin_user
    @@admin_user = User.find_by_login(ADMIN_USER) unless defined?(@@admin_user)
    @@admin_user
  end
  
  # Used by the login form
  def remember_me?
    1
  end
  
  # Used by the new_user form
  def roles=(roles)
    account_user.role_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end
  
  def roles
    is_administrator? ? ROLES : ROLES.reject { |r| ((account_user.role_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role_symbols
    roles.map(&:to_sym)
  end
   
  def member_of?(account)
    accounts.find_by_name(account.name) || is_administrator?
  end
  
  def is_administrator?
    self.administrator?
  end
  alias :admin? :is_administrator?
  
  # Stubs just for forms management
  #def current_password; end  
  #def new_password; end  
  #def new_password_confirmation; end
  #def role; end
    
protected

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

  def update_roles
    account_user.save if @account_user
  end

end
