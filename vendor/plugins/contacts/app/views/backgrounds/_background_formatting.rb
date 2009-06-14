panel I18n.t('contacts.bio_formatting') do
  block do
    text = <<-BACKGROUND
        You can do all sorts of formatting
    BACKGROUND
    store text.textilize
  end
end
