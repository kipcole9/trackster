class Country < ActiveRecord::Base
  #unloadable
  
  def self.name_like(name)
    I18n.translate('countries').reject{|k, v| !(v =~ Regexp.new(".*#{name}.*", true))}
  end

  def self.countries
    @countries ||= I18n.translate('countries')
  end

  def self.name_from(country_code)
    self.countries[country_code.to_sym]
  end
  
  def self.code_for(country)
    self.countries.index(country).try(:to_s)
  end

end
