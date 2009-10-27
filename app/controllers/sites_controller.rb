class SitesController < ApplicationController
  require_role  [Role::ADMIN_ROLE]
  layout 'dashboards'
  
  def show
    date_range = (Date.today - 30).to_s(:db)
    @latency = Track.latency.by(:date).limit(30).filter("date > #{date_range}").all
  end
  
  def _page_title
    "Log update latency"
  end
end
