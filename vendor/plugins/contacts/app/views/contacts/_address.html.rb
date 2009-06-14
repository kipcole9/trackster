with_tag(:div, :class => :address) do
 clear :id => "street" do
    address.hidden_field :id
    address.text_area :street, :size => "30x3", :focus => true, :label_class => :street
    address.select :kind, I18n.translate('contacts.address_types'), :no_label => true
    address.buttons :delete
  end
  address.text_field :locality
  address.text_field :region
  address.text_field :country, :autocomplete => true
  address.text_field :postalcode, :size => 20
end