class Campaign < ActiveRecord::Base
  has_many  :redirects
end
