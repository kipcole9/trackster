class Import < ActiveRecord::Base
  belongs_to      :account
  
  validates_presence_of      :account_id
  validates_associated       :account

end
