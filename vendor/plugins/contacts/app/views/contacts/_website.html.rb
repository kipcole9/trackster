with_tag(:div, :class => :inline) do
  website.hidden_field :id
  website.text_field :url, :focus => true
  website.select :kind, I18n.translate('contacts.website_types'), :no_label => true
  website.buttons :delete
end