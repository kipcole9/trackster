class Background < ActiveRecord::Base
  unloadable if Rails.env == 'development'
  belongs_to      :contact
end
