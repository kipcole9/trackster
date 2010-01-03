panel t('panels.account_update'), :flash => true, :display_errors => :account  do
  block do
    include 'account_form'
  end
end