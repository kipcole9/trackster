section :position => :left do
  organization.hidden_field :account_id
  organization.text_field :name, :validate => :validations, :focus => true
end
section :position => :right do
  organization.text_field :employees
  organization.text_field :revenue
end
