class Website < ActiveRecord::Base
  unloadable  
  belongs_to    :contact
  

end
