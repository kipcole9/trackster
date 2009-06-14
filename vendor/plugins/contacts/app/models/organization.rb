class Organization < Contact
  has_many      :contacts
  
  # Used in autocomplete
  named_scope   :name_like, lambda {|name| {:conditions => ["name like ?", "%#{name}%"], :limit => 10} }
  
  def full_name
    name
  end
  
  def full_name_and_title
    full_name
  end
  
  def organization_name
    name
  end
  
end
