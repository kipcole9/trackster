class Track < ActiveRecord::Base
  include Analytics::Metrics
  include Analytics::Dimensions
  
  formats :tracked_at => {:formatter => lambda{|value|
    if value.day == 1 && value.hour == 0 && value.min == 0 && value.sec == 0
      # It's a month
      value.strftime("%B %Y")
    elsif value.hour == 0 && value.min == 0 && value.sec == 0
      # It's a day
      value.strftime("%Y/%m/%d")      
    else
      value.stftime("%d/%m/%Y %H:%M:%S")
    end
    }
  }
  
  named_scope :limit, lambda {|limit| {:limit => limit} }
  named_scope :order, lambda {|order| {:order => order} }       
  named_scope :filter, lambda {|conditions| {:conditions => conditions} }
  
  named_scope :property, lambda {|property|
    { :conditions => ["property_id = ?", Property.find_by_name(property).try(:id)] } 
  }
end
