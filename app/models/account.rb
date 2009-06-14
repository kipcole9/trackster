class Account < ActiveRecord::Base
  has_many        :properties
  has_many        :traffic_sources
  has_many        :sessions
  has_many        :campaigns
  has_many        :redirects
  has_many        :users
  has_many        :contacts
  
  ADMIN_ACCOUNT     = "Admin"
  ADMIN_DESCRIPTION = "Administration Account"
  
  def self.ensure_admin_exists
    unless admin = find_by_name(ADMIN_ACCOUNT)
      admin = create!(:name => ADMIN_ACCOUNT, :description => ADMIN_DESCRIPTION)
    end
  end
  
  def self.admin_account
    find_by_name(ADMIN_ACCOUNT)
  end
end
