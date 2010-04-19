class Ability
  include CanCan::Ability

  def initialize(user)
    if user && (user.admin? || user.has_role?(:account_admin) || user.has_role?(:account_owner))
      can :manage, :all
    else
      can :read, :all
    end

  end
  
  alias :permitted_to? :can?
end