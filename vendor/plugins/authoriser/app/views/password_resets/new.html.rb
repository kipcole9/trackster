column :before => 3, :width => 6 do
  panel t('panels.reset_password'), :flash => true  do
    block do
      form_for User.new, :url => password_resets_path do |user|
        fieldset t('users.reset_email') do
          user.text_field :email, :prompt => I18n.t('users.reset_instructions')
        end
        submit_combo :text => 'users.reset_button'
      end
    end
  end
end