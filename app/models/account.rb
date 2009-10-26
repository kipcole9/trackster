class Account < ActiveRecord::Base
  has_many        :properties
  has_many        :traffic_sources
  has_many        :sessions
  has_many        :campaigns
  has_many        :redirects
  has_many        :users
  has_many        :contacts
  has_many        :teams
  
  has_attached_file :logo, :styles => { :banner => "400x23" }
  
  validates_format_of :chart_background_colour, :with => /\#(\d|[a-f]|[A-F]){6,6}/, :allow_nil => true, :allow_blank => true
  
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
