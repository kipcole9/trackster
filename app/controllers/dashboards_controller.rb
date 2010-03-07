class DashboardsController < ApplicationController
  before_filter   :get_properties, :only => [:index, :show]
  def show
    render :action => 'index'
  end
  
  def index
  
  end
  
private
  def get_properties
    @properties = current_account.properties.all
    redirect_to property_report_path(@properties.first, 'visit_overview') if @properties.length == 1
  end
  
end
