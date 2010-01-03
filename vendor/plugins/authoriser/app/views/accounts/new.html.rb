panel t('panels.account_new'), :flash => true, :display_errors => :account  do
  block do
    include 'account_form'
  end
end