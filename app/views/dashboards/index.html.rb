@account ||= Account.new
panel t('panels.dashboard'), :flash => true  do
  block do
    store "This is the index page for analytics"
  end
end