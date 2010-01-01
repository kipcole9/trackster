class Email < ActiveRecord::Base
  unloadable  
  belongs_to                :contact
  validates_presence_of     :address
  validates_length_of       :address,         :within => 6..100 #r@a.wk
  validates_format_of       :address,         :with => User::EMAIL_REGEX
  validates_uniqueness_of   :address
  
  
end
