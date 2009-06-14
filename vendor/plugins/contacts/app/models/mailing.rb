class Mailing < ActiveRecord::Base
  belongs_to      :recipient
  belongs_to      :campaign
  
end
