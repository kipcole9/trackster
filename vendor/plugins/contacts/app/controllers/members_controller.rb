class MembersController < ApplicationController
  
  def create
    respond_to do  |format| 
      format.js {
        if params[:team_id]
          create_team_member(params)
        elsif params[:group_id]
          create_group_member(params)
        end 
      }
    end
  end
  
  # Note: we may be called for 'team' members or 'group' members
  def destroy
    if params[:team_id]
      destroy_team_member(params)
    elsif params[:group_id]
      destroy_group_member(params)
    end
  end
  
private
  def create_team_member(params)
    @team = Team.find(params[:team_id])
    if @user = @team.users.find_by_id(params[:id])
      render '/users/highlight_team_user_tag', :locals => {:team => @team, :user => @user}
    else
      @user = User.find(params[:id])
      @team.users << @user
      render :action => 'create_team'
    end
  end
  
  def create_group_member(params)
    @group = Group.find(params[:group_id])
    if @user = @group.users.find_by_id(params[:id])
      render '/users/highlight_group_user_tag', :locals => {:group => @group, :user => @user}
    else
      @user = User.find(params[:id])
      @group.users << @user
      render 'create_group'
    end
  end
  
  def destroy_team_member(params)
    team = Team.find(params[:team_id])
    member = team.team_members.find_by_user_id(params[:id])
    member.destroy
    @team_id = "team_#{params[:team_id]}"
    @user_id = "user_#{params[:id]}"
    render :action => 'destroy_team'
  end
  
  def destroy_group_member(params)
    group = Group.find(params[:group_id])
    member = group.group_members.find_by_user_id(params[:id])
    member.destroy
    @group_id = "group_#{params[:group_id]}"
    @user_id = "user_#{params[:id]}"
    render :action => 'destroy_group'
  end

end
