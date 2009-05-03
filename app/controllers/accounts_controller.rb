class AccountsController < ApplicationController
  require_role  ["admin", "account holder"]
  
  def new
    render :action => 'edit'
  end
  
end
