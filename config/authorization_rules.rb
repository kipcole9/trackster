authorization do
  role :guest do
    # add permissions for guests here, e.g.
    #has_permission_on :conferences, :to => :read
  end
  
  role :admin do
    has_permission_on :accounts,    :to => :manage
    has_permission_on :properties,  :to => :manage
    has_permission_on :campaigns,   :to => :manage
    has_permission_on :contacts,    :to => :manage
  end
  
  role :agent do
    has_permission_on :accounts,    :to => :manage
    has_permission_on :properties,  :to => :manage
    has_permission_on :campaigns,   :to => :manage
    has_permission_on :contacts,    :to => :manage    
  end
  
  role :user do
    has_permission_on :properties,  :to => :read
    has_permission_on :campaigns,   :to => :read
    has_permission_on :contacts,    :to => :read    
  end
  
  role :list_manager do
    has_permission_on :contacts,    :to => :manage
  end
  
  role :campaign_manager do
    has_permission_on :campaigns,   :to => :manage
  end
  
  
  # permissions on other roles, such as
  #role :admin do
  #  has_permission_on :conferences, :to => :manage
  #end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
