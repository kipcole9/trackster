class AccountUser < ActiveRecord::Base
  unloadable
  belongs_to  :user
  belongs_to  :account
  
  ROLES = %w[account_owner account_admin campaign_manager designer crm_manager user]
  
  # Used by the new_user form
  def roles=(roles)
    roles = [roles] unless roles.is_a?(Array)
    roles.map! {|r| r.to_s}
    self.role_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end
  
  def roles
    ROLES.reject { |r| ((self.role_mask || 0) & 2**ROLES.index(r)).zero? }
  end
  
  def has_role?(role)
    roles.include?(role.to_s)
  end
  
end
