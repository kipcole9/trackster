class InstantMessenger < ActiveRecord::Base
  unloadable if Rails.env == 'development'
end
