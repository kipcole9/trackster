class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaigns
  
  include Analytics::Metrics
  include Analytics::Dimensions
  
  table_format :count,      :total => :sum
  table_format :page_views, :total => :sum, :class => 'page_views right'
  table_format :visits,     :total => :sum, :class => 'visits right'
  table_format :visitors,   :total => :sum, :class => 'visitors right'
      
  named_scope :limit, lambda {|limit| {:limit => limit} }
  named_scope :order, lambda {|order| {:order => order} }       
  named_scope :filter, lambda {|conditions| {:conditions => conditions} }
  
  named_scope :property, lambda {|property|
    { :conditions => ["property_id = ?", Property.find_by_name(property).try(:id)] } 
  }
end
