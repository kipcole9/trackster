caerus_form_for (@group || Group.new) do |group|
  fieldset t('.add_new_group') do
    group.text_field :name, :focus => true
    group.text_field :description
  end
  submit_combo
end
