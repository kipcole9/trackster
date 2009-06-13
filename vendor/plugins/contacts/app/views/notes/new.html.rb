caerus_form_for @note do |note|
  fieldset "Enter your new note:" do
    section :postion => :left do
      note.hidden_field :notable_type
      note.hidden_field :notable_id
      note.text_area :note, :size => "35x3"
    end
    section :position => :right do
      note.date_select :related_date
    end
  end
  submit_combo
end
