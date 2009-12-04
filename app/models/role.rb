class Role < ActiveRecord::Base
  ADMIN_ROLE        = "admin"
  ACCOUNT_ROLE      = "account holder"
  USER_ROLE         = "user"
  
  has_many          :account_users
  
  def self.find_or_create(role)
    role_name = role.to_s
    role = find_by_name(role_name) || create!(:name => role_name)
  end
  
  def self.ensure_roles_exist
    find_or_create(ADMIN_ROLE)
    find_or_create(ACCOUNT_ROLE)
    find_or_create(USER_ROLE)
  end
  
  def self.available_roles(user)
    if user.has_role?(ADMIN_ROLE)
      [["Site administrator", ADMIN_ROLE], ["Account administrator", ACCOUNT_ROLE], ["Account user", USER_ROLE]]
    else  
      [["Account administrator", ACCOUNT_ROLE], ["Account user", USER_ROLE]]
    end
  end
end