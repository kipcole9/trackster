class SitesController < ApplicationController
  require_role  [Role::ADMIN_ROLE]
  layout 'dashboards'
  
  def show
    @latency = Track.latency.by(:date).all
  end
  
end
