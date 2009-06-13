class Person < Contact
  belongs_to    :organization
  
  def organization_name=(name)
    self.organization = Organization.find_or_create_by_name(:name => name, :account_id => self.account_id)
  end

  def organization_name
    self.try(:organization).try(:name)
  end

  def full_name
    names_in_order.join(' ')
  end

  def formal_name
    [honorific_prefix, names_in_order, honorifix_suffix].flatten.compact.join(' ')
  end

  def full_name_and_title
    [self.full_name, self.role, self.organization_name].compact.join(', ')
  end

  def formal_name_and_title
    [self.formal_name, self.role, self.organization_name].compact.join(', ')
  end

private
  def names_in_order
    if self.name_order == "gf"
      [given_name, family_name]
    else
      [family_name, given_name]
    end
  end
  
  
end
