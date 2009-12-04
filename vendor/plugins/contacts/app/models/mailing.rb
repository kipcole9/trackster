class Mailing < ActiveRecord::Base
  unloadable
  belongs_to      :recipient
  belongs_to      :campaign
  
end
