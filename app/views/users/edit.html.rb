@user_sidebar = 'new_user_help'
panel t('panels.user'), :flash => true, :display_errors => 'user'  do
  block do
    caerus_form_for @user, :html => { :multipart => true } do |user|
      fieldset t('.edit_user', :name => @user.name) do
        user.text_field       :login, :disabled => true unless edit_action?
        user.text_field       :given_name
        user.text_field       :family_name        
        user.text_field       :email
        user.select           :locale, [["English", 'en-US']]
        user.time_zone_select :timezone, time_zones_like(Time.zone), :default => Time.zone.name        
        user.file_field       :photo
      end
      submit_combo
    end
  end
end