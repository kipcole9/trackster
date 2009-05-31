panel t('panels.property'), :flash => true  do
  block do
    store render :partial => 'property_detail', :locals => {:property => @property}
  end
end