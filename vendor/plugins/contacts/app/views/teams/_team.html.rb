caerus_form_for (@team || Team.new) do |team|
  fieldset t('.add_new_team') do
    team.hidden_field :parent_id
    team.text_field :name, :focus => true
    team.text_field :description
  end
  submit_combo
end
