class Organization < Contact
  unloadable if Rails.env == 'development' 
  has_many      :contacts
  
  # Used in autocomplete
  named_scope   :name_like, lambda {|name| {:conditions => ["name like ?", "%#{name}%"], :limit => 20} }
  
  def full_name
    name
  end
  
  def full_name_and_title
    full_name
  end
  
  def organization_name
    name
  end
  
  def revenue=(rev)
    return if rev.blank?
    delimiter = I18n.t('activerecord.number.format.delimiter')
    rev_value = rev.to_s.gsub(/[ #{delimiter}]/,'').to_f
    if rev =~ /[kK]\Z/
      rev_value = rev_value * 1_000
    elsif rev =~ /[mM]\Z/
      rev_value = rev_value * 1_000_000
    end
    super rev_value
  end
  
  def employees=(emp)
    return if emp.blank?
  end
  
  def industry=(ind)
    return if ind.blank?
  end
  
end
