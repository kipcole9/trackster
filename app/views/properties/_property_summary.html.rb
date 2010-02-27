clear do
  float :left do
    img (property.thumb? ? property.thumb(:thumb) : '/images/list_icons/property.png'), :class => :list_image
  end
  float :left do
    h4 link_to("#{property.name} (#{property.tracker})", property_report_path(property, "overview"))
    p property.description, :style => (property.description.blank? ? "display:none" : "")
    p link_to(property.url, property.url)
  end
end
