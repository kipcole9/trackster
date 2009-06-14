class Team < ActiveRecord::Base
  acts_as_nested_set :scope => :account
  
  has_many      :team_members
  has_many      :users, :through => :team_members
  
end
