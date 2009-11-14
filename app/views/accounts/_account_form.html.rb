caerus_form_for @account, :html => { :multipart => true } do |account|
  fieldset t('accounts.account') do
    account.text_field     :name
    account.text_area      :description
  end
  fieldset t('accounts.presentation') do
    account.text_field     :theme
    store image_tag(@account.logo(:banner)) if @account.logo?
    account.file_field     :logo
  end
  submit_combo
end