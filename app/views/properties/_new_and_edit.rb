panel t('panels.property'), :display_errors => :property  do
  block do
    store render :partial => 'property_form', :locals => {:property => @property}
  end
end