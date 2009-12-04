class TeamMember < ActiveRecord::Base
  unloadable  
  belongs_to      :team
  belongs_to      :user
  
end
