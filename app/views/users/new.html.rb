@user ||= User.new
panel t('panels.new_user'), :flash => true, :display_errors => :user  do
  block do
    caerus_form_for @user do |user|
      fieldset t('.new_user') do
        user.text_field :login,       :validate => :validations
        user.text_field :given_name,  :validate => :validations
        user.text_field :family_name, :validate => :validations
        user.text_field :email,       :validate => :validations
      end
      fieldset t('.type_of_new_user') do
        user.select :role, User::ROLES, :selected => User::ROLES.first
      end
      submit_combo
    end
  end
end

keep :sidebar do
  store render 'sidebar_new'
end
