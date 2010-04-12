class Address < ActiveRecord::Base
  unloadable if Rails.env == 'development'
  belongs_to    :contact

  def country=(name)
    return nil if name.blank?
    super Country.code_for(name) || name
  end
  
  def country
    return nil unless self['country']
    Country.name_from(self['country'])
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
