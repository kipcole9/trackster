class DashboardsController < ApplicationController

  def show
    redirect_to account_report_path(:action => 'visit_overview')
  end
  
  def index
    redirect_to account_report_path(:action => 'visit_overview')
  end

end
