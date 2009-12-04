@account ||= Account.new
panel @account.new_record? ? t('panels.account_new') : t('panels.account_update'), :flash => true, :display_errors => :account  do
  block do
    include 'account_form'
  end
end