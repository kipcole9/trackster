panel t('panels.new_import')  do
  block do
    caerus_form_for @import, :html => { :multipart => true }  do |import|
      fieldset I18n.t('imports.import_dialog') do
        import.text_field     :description
        import.file_field     :source_file
      end
      submit_combo :text => 'imports.import_button'
    end
  end
end