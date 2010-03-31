with_tag(:div, :class => :inline) do
  phone.hidden_field  :id
  phone.text_field    :number, :validate => :validations, :focus => true
  phone.check_box     :preferred, :class => 'preferred', :no_label => true, :title => tt('preferred')
  phone.select        :kind, I18n.translate('contacts.phone_types'), :no_label => true
  phone.buttons       :delete
end