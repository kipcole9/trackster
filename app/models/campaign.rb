class Campaign < ActiveRecord::Base
  named_scope   :user, lambda {|user|
    {:conditions => {:property_id => user.properties.map(&:id)} }
  }
end
