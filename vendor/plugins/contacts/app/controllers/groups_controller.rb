class GroupsController < ApplicationController
  before_filter   :retrieve_group, :only => [:update, :show, :edit, :destroy]
  before_filter   :retrieve_groups, :only => [:index]

  def show
    render :action => 'new'
  end

  def create
    @group = current_account.groups.create(params[:group])
    respond_to do |format|
      format.js {

      }
      format.html {
        flash[:notice] = "Group added successfully"
        redirect_back_or_default('/')
      }
    end
  end    

  def update
    @group.update_attributes!(params[:group])
    respond_to do |format|
      format.js {

      }
      format.html {
        flash[:notice] = "Group updated successfully"
        redirect_back_or_default('/')
      }
    end
  end
  
  def destroy
    @group.destroy
  end
  
  def index
    respond_to do |format|
      format.js { render(:partial => 'new_group_summary', :collection => @groups, :as => :group) }
      format.html
    end
  end

private
  def retrieve_group
    @group = current_account.groups.find(params[:id])
  end

  def retrieve_groups
    @groups = current_account.groups.find(:all, :conditions => conditions_from_search(params[:search]))
  end

  def conditions_from_search(search)
    return '' if search.blank?
    conditions = []
    names = search.split(' ').map(&:strip)
    names.each do |name|
      conditions << "name LIKE '%#{quote_string(name)}%' OR description LIKE '%#{quote_string(name)}%'" unless name.blank?
    end
    conditions.join(' OR ')
  end

  def quote_string(string)
    ActiveRecord::Base.connection.quote_string(string)
  end

end
