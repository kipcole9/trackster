with_tag(:div, :class => :inline) do
  email.hidden_field :id
  email.text_field :address, :validate => :validations, :focus => true
  email.check_box :preferred, :class => 'preferred', :no_label => true, :title => tt('preferred')
  email.select :kind, I18n.translate('contacts.email_types'), :no_label => true
  email.buttons :delete
end