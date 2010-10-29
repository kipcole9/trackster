panel t('panels.content_form'), :display_errors => 'content' do
  block do
    include 'content_form'
  end
end

keep :sidebar do
  column :width => 4, :class => "sidebar help" do
    include 'new_content'
	end
end