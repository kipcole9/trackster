require File.join(File.dirname(__FILE__), "lib", "ruby_template")
ActionView::Template.register_template_handler :rb, ActionView::TemplateHandlers::RubyTemplate