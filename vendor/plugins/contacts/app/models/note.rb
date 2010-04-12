class Note < ActiveRecord::Base
  unloadable if Rails.env == 'development'
  belongs_to    :notable, :polymorphic => true
  belongs_to    :created_by, :class_name => "User", :foreign_key => :created_by
  belongs_to    :updated_by, :class_name => "User", :foreign_key => :updated_by
  
  
end
