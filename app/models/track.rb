class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaign
  belongs_to     :account

  NON_METRIC_KEYS = [:scoped, :source, :between, :by, :duration, :order, :label, :filter, :limit, :having]
  
  # Dimensions here will automatically have IS NOT NULL appended to their conditions
  NON_NULL_DIMENSIONS = [:referrer, :search_terms, :referrer_host, :campaign_name, :local_hour, :url]
    
  include Analytics::Metrics
  include Analytics::Dimensions
  include Analytics::ColumnFormats

  named_scope :having, lambda {|having| {:having => having} }
  named_scope :limit, lambda {|limit| {:limit => limit} }
  named_scope :order, lambda {|order| {:order => order} }       
  named_scope :filter, lambda {|conditions| {:conditions => conditions} }
  named_scope :property, lambda {|property|
    if property.is_a?(Property)
      { :conditions => ["property_id = ?", property.id] } 
    else
      { :conditions => ["property_id = ?", Property.find_by_name(property).try(:id)] } 
    end
  }
  
end
