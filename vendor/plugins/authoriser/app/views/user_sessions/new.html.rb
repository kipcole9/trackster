column :before => 3, :width => 6 do
  panel t('authorizer.login_panel'), :class => :login, :flash => true  do
    block do
      form_for @user_session do |user|
        fieldset t('authorizer.please_log_in') do
          user.text_field     :email, :prompt => false        
          user.password_field :password, :prompt => false
          user.check_box      :remember_me?
        end
        submit_button :text => t('authorizer.login_button')
      end
      with_tag :div, :class => :login_options do
        concat "#{t('authorizer.help')}:  #{link_to(t('authorizer.forgotten_password'), reset_password_path)}"
      end
    end
  end
end
