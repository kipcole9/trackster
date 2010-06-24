with_tag(:div, :class => "flash_#{key}") do
  with_tag(:p) do
    store "#{image_tag("/images/icons/flash_#{key}.png")} #{message}"
  end
end



