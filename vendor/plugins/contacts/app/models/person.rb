class Person < Contact
  unloadable  
  belongs_to              :organization, :autosave => true
  validate                :must_have_name_or_code
  validates_uniqueness_of :contact_code, :scope => :account_id, :allow_blank => true
  
  def organization_name=(name)
    self.organization = account.organizations.find_by_name(name) || account.organizations.create(:name => name) unless name.blank?
  end

  def organization_name
    self.organization.try(:name)
  end

  def full_name
    names_in_order.join(' ')
  end

  def formal_name
    [honorific_prefix, names_in_order, honorific_suffix].flatten.compress.join(' ')
  end

  def full_name_and_title
    [self.full_name, self.role, self.organization_name].compress.join(', ')
  end

  def formal_name_and_title
    [self.formal_name, self.role, self.organization_name].compress.join(', ')
  end

  def informal_name
    self.nickname || self.given_name
  end

  def salutation
    if salutation_template
      interpolate_salutation_template(salutation_template)
    else
      I18n.t("contacts.salutation", :informal_name => self.informal_name)
    end
  end
  
  def job_level=(level)
    return if level.blank?
  end
  
  def job_function=(function)
    return if function.blank?
  end


private
  def names_in_order
    if self.name_order == "gf"
      [given_name, family_name]
    else
      [family_name, given_name]
    end
  end
  
  def interpolate_salutation_template(template)
    return '' if template.blank?
    %w(formal_name given_name family_name formal_name_and_title informal_name full_name full_name_and_title nickname).each do |name|
      value = send(name.to_sym) || ''
      template.gsub!("[[#{name}]]", value)
    end
    template
  end
end
