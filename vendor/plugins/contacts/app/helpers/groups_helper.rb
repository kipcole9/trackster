module GroupsHelper
  def group_id(group)
    "group_#{group['id']}"
  end
  
  def group_member_id(group)
    "groupMember_#{group['id']}"
  end  
end
