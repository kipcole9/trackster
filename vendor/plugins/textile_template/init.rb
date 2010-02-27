require File.join(File.dirname(__FILE__), "lib", "textile_template")
ActionView::Template.register_template_handler :textile, ActionView::TemplateHandlers::TextileTemplate