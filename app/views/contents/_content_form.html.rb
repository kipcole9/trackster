form_for @content, :html => {:multipart => true} do |content|
  tab "content" do  
    tab_item content.object.new_record? ? t('.new_content') : t('.edit_content', :name => content.object.name) do
      content.text_field       :name
      content.text_area        :description
      content.select           :purpose, t('.purpose')
    end
    tab_item t('.source') do
      p "Enter either the URL where your content is located <em>OR</em> select the local file that contains the content"
      content.text_field       :url
      content.file_field       :content_file
      content.text_field       :base_url
    end
  end
  submit_combo
end
