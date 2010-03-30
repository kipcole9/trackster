section :position => :left do
  person.text_field :given_name, :validate => :validations, :focus => true
  person.text_field :family_name
  person.select     :name_order, tt('contacts.name_order'), :optional => true
  person.select     :gender, tt('contacts.gender'), :optional => true
  person.text_field :nickname, :optional => true
  person.text_field :honorific_prefix, :optional => true
  person.text_field :honorific_suffix, :optional => true
end
section :position => :right do
  person.text_field :role
  person.text_field :organization_name, :autocomplete => true
  person.text_field :salutation_template, :optional => true
  person.text_field :contact_code, :optional => true
  img @contact.photo.url(:avatar) if @contact.photo?
  person.file_field :photo, :size => 20
end
