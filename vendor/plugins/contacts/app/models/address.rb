class Address < ActiveRecord::Base
  belongs_to    :contact

  def country=(name)
    return nil if name.blank?
    self["country"] = countries.index(name).to_s || name
  end
  
  def country
    return nil if self["country"].blank?
    countries[self["country"].to_sym] || self["country"]
  end
  
  def countries
    @countries ||= I18n.translate('countries')
  end
  
  # So the form builder will ask us properly for the country value
  # Don't know why it defaults to using before_type_case
  # The way it works is that if the before_type_case method doesn't
  # exist it just calls the normal method
  def respond_to?(method)
    return false if method == "country_before_type_cast"
    super
  end

end
