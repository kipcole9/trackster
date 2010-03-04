class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin? || user.has_role?(:account_admin)
      can :manage, :all
    else
      can :read, :all
    end

  end
  
  alias :permitted_to? :can?
end