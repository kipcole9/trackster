class Group < ActiveRecord::Base
  default_scope :order => "name DESC"
  has_many      :group_members, :dependent => :destroy
  has_many      :users, :through => :group_members
  
end
