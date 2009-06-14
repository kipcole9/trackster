class Email < ActiveRecord::Base
  belongs_to                :contact
  validates_presence_of     :address
  validates_length_of       :address,         :within => 6..100 #r@a.wk
  validates_format_of       :address,         :with => Authentication.email_regex
  validates_uniqueness_of   :address
  
  
end
