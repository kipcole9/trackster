class Background < ActiveRecord::Base
  unloadable  
  belongs_to      :contact
end
