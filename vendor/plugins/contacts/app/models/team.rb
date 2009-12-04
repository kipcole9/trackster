class Team < ActiveRecord::Base
  unloadable  
  acts_as_nested_set :scope => :account
  
  has_many      :team_members
  has_many      :users, :through => :team_members
  has_many      :contacts
  
end
