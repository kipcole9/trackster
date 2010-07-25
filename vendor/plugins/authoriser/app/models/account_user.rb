class AccountUser < ActiveRecord::Base
  unloadable
  belongs_to  :user
  belongs_to  :account
  
  # Don't change the order of these - they represent a bitmap and reordering will cause
  # bad things to happen.  Add new roles to the end of the list no problem.
  ROLES = %w[account_owner account_admin campaign_manager designer crm_manager user api_access]
  
  # Used by the new_user form
  def roles=(roles)
    roles = [roles] unless roles.respond_to?(:map) && roles.respond_to?(:&) #  is_a?(Array)
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
