require 'digest/sha1'

class User < ActiveRecord::Base

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  
  has_many                  :account_users, :autosave => true
  has_many                  :accounts, :through => :account_users
  after_save                :update_roles
  
  ADMIN_USER                = 'admin'
  ADMIN_DEFAULT_PASSWORD    = 'admin123'
  ADMIN_DEFAULT_EMAIL       = 'admin@example.com'
  ADMIN_NAME                = "Administrator"
  VALID_USER_NAME           = /\A[^[:cntrl:]\\<>\/&]+\z/
  
  ROLES                     = %w[admin agent sponsor user]
  
  has_attached_file         :photo, :styles => { :avatar => "50x50#" },
                            :convert_options => { :all => "-unsharp 0.3x0.3+3+0" }
  
  has_many                  :account_users
  has_many                  :accounts, :through => :account_users
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :given_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :given_name,     :maximum => 100
  validates_format_of       :family_name,    :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :family_name,    :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :given_name, :family_name, :password, :password_confirmation, 
                  :account, :remember_me?, 
                  :locale, :timezone, :role, :photo, :property_ids, :name,
                  # Virtual attributes we use for changing password - make sure we don't interrupt the real data
                  :new_password, :new_password_confirmation
                  
  attr_accessor   :current_account

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password, account)
    return nil if login.blank? || password.blank? || account.blank?
    return nil unless account = Account.find_by_name(account)
    u = account.users.find :first, :conditions => ['login = ? and state = ?', login.downcase, 'active']
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def name
    [self.given_name, self.family_name].compress.join(' ').strip
  end
  
  def self.admin_user
    @@admin_user = User.find_by_login(ADMIN_USER) unless defined?(@@admin_user)
    @@admin_user
  end
  
  # When the server starts this method is invoked post-initialization
  # to ensure that we have an admin user.  This is most helpful when
  # booting a new system.  Or if someone does something silly to the database
  # behind the scenes.
  def self.ensure_admin_exists
    unless User.find_by_login(ADMIN_USER)
      admin = User.create!(:login => ADMIN_USER, :password => ADMIN_DEFAULT_PASSWORD, 
        :password_confirmation => ADMIN_DEFAULT_PASSWORD, :email => ADMIN_DEFAULT_EMAIL,
        :family_name => ADMIN_NAME)
      admin.state = 'active'
      admin.account = Account.admin_account
      admin.save!
    end
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
  
  # Stubs just for forms management
  def current_password; end  
  def new_password; end  
  def new_password_confirmation; end
  def role; end
    
protected

  def account_user
    @account_user ||= account_users.find_by_account_id(Authorization.current_user.current_account.id)
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

  def update_roles
    account_user.save if @account_user
  end

end
