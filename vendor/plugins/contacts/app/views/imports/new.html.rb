panel t('panels.new_import')  do
  block do
    caerus_form_for @import, :html => { :multipart => true }  do |import|
      fieldset I18n.t('imports.import_dialog') do
        import.file_field     :import
      end
    end
  end
end