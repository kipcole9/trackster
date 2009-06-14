class TeamsController < ApplicationController
  before_filter   :retrieve_team, :only => [:update, :show, :edit, :destroy]
  before_filter   :retrieve_teams, :only => [:index]

  def show
    render :action => 'new'
  end
  
  def create
    parent = params[:team].delete(:parent_id)
    Team.transaction do
      @team = current_account.teams.create(params[:team])
      @team.move_to_child_of(parent)
    end
    respond_to do |format|
      format.js {
        @team_id = "team_#{@team['id']}"
        @parent_id = "team_#{parent}"
      }
      format.html {
        flash[:notice] = "Team added successfully"
        redirect_back_or_default('/')
      }
    end
  end    
  
  def update
    params[:team].delete(:parent_id)
    retcode =  @team.update_attributes(params[:team])
    respond_to do |format|
      format.js {
        @team_id = "team_#{@team['id']}"
      }
      format.html {
        flash[:notice] = "Team updated successfully"
        redirect_back_or_default('/')
      }
    end
  end
  
  def merge
    @team_from = Team.find(params[:team_from_id])
    @team_to = Team.find(params[:team_to_id])
    @new_teams_ul = "\"<ul class='teams'></ul>\""
    respond_to do |format|
      format.js {
        if @team_to.is_descendant_of?(@team_from)
          render :action => 'merge_not_possible'
        else
          @team_from.move_to_child_of(@team_to)
        end
      }
    end
  end
  

private
  def retrieve_team
    @team = current_account.teams.find(params[:id])
  end
  
  def retrieve_teams
    @teams = current_account.teams.all
  end

end
