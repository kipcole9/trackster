panel t('panels.new_user'), :flash => true, :display_errors => :user  do
  block do
    form_for @user || User.new do |user|
      fieldset t('users.new_user') do
        user.text_field :email,       :validate => :validations
        user.text_field :given_name,  :validate => :validations
        user.text_field :family_name, :validate => :validations
      end
      fieldset t('users.user_roles', :account_name => current_account.name) do
        user.text_field       :tags, :class => 'tags'
        user_roles_check_boxes(@user)
      end if can? :create, User
      submit_combo
    end
  end
end

keep :sidebar do
  include 'users/sidebars/new_user'
end