@account ||= Account.new
panel t('panels.account'), :flash => true  do
  block do
    include 'account_form'
  end
end