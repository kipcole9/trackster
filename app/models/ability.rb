class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    elsif user.has_role?(:account_admin) || user.has_role?(:account_owner)
      can :manage, :all
    else
      can :read, [Property, Campaign, Content, Contact, Person, Organization]
      can :update, User, :id => user.id
    end

  end
  
  alias :permitted_to? :can?
end