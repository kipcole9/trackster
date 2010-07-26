panel t('panels.account_new'), :display_errors => :account  do
  block do
    include 'account_form'
  end
end

keep :sidebar do
  include 'account_form_help'
end