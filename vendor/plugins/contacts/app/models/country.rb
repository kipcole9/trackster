class Country < ActiveRecord::Base
  
  def self.name_like(name)
    I18n.translate('countries').reject{|k, v| !(v =~ Regexp.new(".*#{name}.*", true))}
  end
  
  def all
    I18N.translate('countries')
  end

end
