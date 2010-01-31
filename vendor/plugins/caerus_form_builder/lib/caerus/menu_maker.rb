module Caerus
  module MenuMaker
    def main_menu(options = {})
      with_tag :ul, {:class => "nav main"}.merge(options) do
        yield if block_given?
      end
    end
  
    def menu_item(item, options = {})
      with_tag :li do
        with_tag :a, options do
          store item
        end
        with_tag :ul do
          yield
        end if block_given?
      end
    end

  end
end
