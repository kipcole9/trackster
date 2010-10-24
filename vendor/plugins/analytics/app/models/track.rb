class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaign
  belongs_to     :account
  belongs_to     :content
  belongs_to     :property

  NON_METRIC_KEYS = [:scoped, :source, :between, :by, :duration, :order, :label, :filter, :limit, :having, :active, :ip_filter]
  
  # Dimensions here will automatically have IS NOT NULL appended to their conditions
  NON_NULL_DIMENSIONS = [:referrer, :search_terms, :referrer_host, :campaign_name, :local_hour, :url, :contact_code, 
                        :clicks_through, :date, :day_of_month, :hour, :day_of_week, :month, :year]
    
  include Analytics::Model::Filters  
  include Analytics::Model::Metrics
  include Analytics::Model::Stream
  include Analytics::Model::Dimensions
  include Analytics::Model::ColumnFormats
  include Analytics::Model::Utils
  
end
