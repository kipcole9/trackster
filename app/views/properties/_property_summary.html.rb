clear do
  float :left do
    img (property.thumb? ? property.thumb(:thumb) : '/images/list_icons/property.png'), :class => :list_image
  end
  float :left do
    h4 link_to(h(property.name), property_report_path(property, "visit_overview"))
    p h(property.description), property_style(property)
    p link_to(property.url, property.url)
  end
end
