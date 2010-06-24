panel t('panels.user'), :display_errors => 'user'  do
  block do
    form_for @user, :html => { :multipart => true } do |user|
      tab "user" do
        tab_item t('users.edit_user', :name => @user.name) do
          user.text_field       :email
          user.text_field       :given_name
          user.text_field       :family_name        
          user.select           :locale, locales, :default => I18n.locale
          user.time_zone_select :timezone, time_zones_like(Time.zone), :default => Time.zone.name, :include_blank => true       
          user.file_field       :photo
        end
        tab_item t('users.user_state') do
          user.select           :state, user_states, :default => I18n.t('users.states.passive')
        end if can? :create, User
        tab_item t('users.user_roles', :account_name => current_account.name) do
          user.text_field       :tags, :class => 'tags'
          user_roles_check_boxes(@user)
        end if can? :create, User
        tab_item t('users.change_password') do
          user.password_field   :password
          user.password_field   :new_password
          user.password_field   :new_password_confirmation
        end
        tab_item t('users.api_key') do
          include :partial => 'api_key', :locals => {:api_key => @user.single_access_token}
        end
      end
      submit_combo
    end
  end
end