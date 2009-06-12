class SitesController < ApplicationController
  require_role  [Role::ADMIN_ROLE]
  layout 'dashboards'
  
  def show
    @latency = Track.latency.by(:date).all
  end
  
  def _page_title
    "Log update latency"
  end
end
