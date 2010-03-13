class DashboardsController < ApplicationController
  before_filter   :get_properties, :only => [:index, :show]
  def show
    redirect_to account_report_path(:action => 'visit_overview')
  end
  
  def index
    redirect_to account_report_path(:action => 'visit_overview')
  end
  
private
  def get_properties
    @properties = current_account.properties.all
  end
  
end
