class Track < ActiveRecord::Base
  set_table_name :sessions
  has_many       :events, :foreign_key => :session_id
  belongs_to     :campaigns
  
  include Analytics::Metrics
  include Analytics::Dimensions
  include Analytics::ParamParser
  extend ActionView::Helpers::NumberHelper
  
  table_format :count,      :total => :sum, :order => 99
  table_format :page_views, :total => :sum, :class => 'page_views right', :order => 99
  table_format :visits,     :total => :sum, :class => 'visits right', :order => 99
  table_format :visitors,   :total => :sum, :class => 'visitors right', :order => 99
  table_format :percent_of_visits, :total => :sum, :class => 'visits right', :order => 98, :formatter => lambda{|num| self.number_to_percentage(num, :precision => 1) }
  table_format :percent_of_page_views, :total => :sum, :class => 'page_views right', :order => 98, :formatter => lambda{|num| self.number_to_percentage(num, :precision => 1) }
    
  #chart_format :date,      :formatter => lambda{|date| "#{date.day} #{I18n.t('date.abbr_month_names')[date.month]}"}
  #chart_format :month,     :formatter => lambda{|month| I18n.t('date.abbr_month_names')[month]}
  #chart_format :day,       :formatter => lambda{|day| I18n.t('date.abbr_day_names')[day]}       
  
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
