# Shows site latency
class SitesController < ApplicationController
  layout 'dashboards'
  
  def show
    date_range = (Date.today - 30).to_s(:db)
    @latency = Track.latency.order('date desc').by(:date).limit(30).filter("date > #{date_range}").all.sort{|a,b| a.date <=> b.date}
  end
  
protected  
  def page_title
    "Log update latency"
  end
end
