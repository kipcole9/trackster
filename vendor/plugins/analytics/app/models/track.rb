class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaign
  belongs_to     :account

  NON_METRIC_KEYS = [:scoped, :source, :between, :by, :duration, :order, :label, :filter, :limit, :having]
  
  # Dimensions here will automatically have IS NOT NULL appended to their conditions
  NON_NULL_DIMENSIONS = [:referrer, :search_terms, :referrer_host, :campaign_name, :local_hour, :url]
    
  include Analytics::Model::Filters  
  include Analytics::Model::Metrics
  include Analytics::Model::Dimensions
  include Analytics::Model::ColumnFormats
  include Analytics::Model::Utils
  
end
