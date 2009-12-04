class EagerLoader < Rails::Plugin::Loader 
  def add_plugin_load_paths 
    super 
    engines.each do |engine| 
      if configuration.cache_classes 
        configuration.eager_load_paths += engine.load_paths 
      end 
    end 
  end 
end
