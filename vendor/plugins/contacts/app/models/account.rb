class Account < ActiveRecord::Base
  has_many                  :users
  has_many                  :contacts
  has_many                  :sites
  has_many                  :teams
  has_many                  :groups, :order => "name"
  
  composed_of               :calendar, :class_name => "CalendarProxy",
                            :mapping  => CalendarProxy::COMPOSED_OF_MAPPING
                            
  attr_accessible           :name, :timezone, :calendar, :description
  
  VALID_ACCOUNT_NAME        = /\A[[:alnum:]][[:alnum:]\.\-]+\z/
  
  validates_presence_of     :name
  validates_format_of       :name,     :with => VALID_ACCOUNT_NAME
  validates_length_of       :name,     :within => 3..40
  validates_uniqueness_of   :name
  validates_exclusion_of    :name,     :in => %w( support blog www billing help api )
  
end