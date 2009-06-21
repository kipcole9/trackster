module PropertiesHelper
  def list_id(list)
    "list_#{list['id']}"
  end
  
  def list_member_id(list)
    "listMember_#{list['id']}"
  end

  def report_params(options = {})
    params.merge(options)
  end
end
