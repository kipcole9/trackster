panel t('panels.redirect'), :flash => true, :display_errors => 'redirect'  do
  block do
    store render :partial => 'redirect_form', :locals => {:redirect => @redirect}
  end
end