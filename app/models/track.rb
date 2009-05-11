class Track < ActiveRecord::Base
  include Analytics::Metrics
  include Analytics::Dimensions
  
end
