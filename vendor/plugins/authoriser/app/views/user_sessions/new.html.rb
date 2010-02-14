column :before => 3, :width => 6 do
  panel t('panels.login'), :class => :login, :flash => true  do
    block do
      caerus_form_for @user_session do |user|
        fieldset t('log_in') do
          user.text_field     :login, :prompt => false        
          user.password_field :password, :prompt => false
          user.check_box      :remember_me?
        end
        submit_combo :text => 'login'
      end
    end
  end
end
