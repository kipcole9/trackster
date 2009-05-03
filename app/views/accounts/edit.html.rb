@account ||= Account.new
panel t('panels.account'), :flash => true  do
  block do
    caerus_form_for @account do |account|
      fieldset t('.account') do
        account.text_field     :name
        account.text_area      :description
      end
    
      submit_combo
    end
  end
end