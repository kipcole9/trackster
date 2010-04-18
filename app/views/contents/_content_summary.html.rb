clear do
  float :left do
    img '/images/list_icons/content.png', :class => :list_image
  end
  float :left do
    h4 link_to("#{content.name}", content_path(content))
    p content.description, :style => (content.description.blank? ? "display:none" : "")
  end
end


