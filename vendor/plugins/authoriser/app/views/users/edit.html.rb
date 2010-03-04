panel t('panels.user'), :flash => true, :display_errors => 'user'  do
  block do
    caerus_form_for @user, :html => { :multipart => true } do |user|
      fieldset t('.edit_user', :name => @user.name) do
        user.text_field       :email, :disabled => 'disabled'
        user.text_field       :given_name
        user.text_field       :family_name        
        user.select           :locale, [["English", 'en-US']]
        user.time_zone_select :timezone, time_zones_like(Time.zone), :default => Time.zone.name        
        user.file_field       :photo
      end
      fieldset t('.user_roles') do
        User::ROLES.each do |r|
          with_tag(:div) do
            store check_box_tag("roles[]", r, @user.has_role?(r))
            store content_tag(:label, r.humanize, :class => :field_label)
          end
        end
        nil
      end
      submit_combo
    end
  end
end