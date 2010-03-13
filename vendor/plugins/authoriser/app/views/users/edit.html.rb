panel t('panels.user'), :flash => true, :display_errors => 'user'  do
  block do
    caerus_form_for @user, :html => { :multipart => true } do |user|
      fieldset t('.edit_user', :name => @user.name) do
        user.text_field       :email
        user.text_field       :given_name
        user.text_field       :family_name        
        user.select           :locale, locales, :default => I18n.locale
        user.time_zone_select :timezone, time_zones_like(Time.zone), :default => Time.zone.name        
        user.file_field       :photo
      end
      fieldset t('users.user_state') do
        user.select           :state, user_states, :default => I18n.t('users.states.passive')
      end if can? :create, User
      fieldset t('users.user_roles', :account_name => current_account.name) do
        user.text_field       :tags, :class => 'tags'
        user_roles_check_boxes(@user)
      end if can? :create, User
      submit_combo
    end
  end
end