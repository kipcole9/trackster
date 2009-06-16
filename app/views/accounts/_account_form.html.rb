caerus_form_for @account, :html => { :multipart => true } do |account|
  fieldset t('accounts.account') do
    account.text_field     :name
    account.text_area      :description
  end
  fieldset t('accounts.presentation') do
    account.text_field     :theme
    account.file_field     :logo
  end
  submit_combo
end