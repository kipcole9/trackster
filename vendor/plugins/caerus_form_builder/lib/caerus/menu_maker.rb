module Caerus
  module MenuMaker
    def main_menu(options = {})
      with_tag :ul, {:class => "nav main"}.merge(options) do
        yield if block_given?
      end
    end
  
    def menu_item(item, link_options = {}, item_options = {})
      with_tag :li, item_options do
        with_tag :a, link_options do
          store item
        end
        with_tag :ul do
          yield
        end if block_given?
      end
    end

  end
end
