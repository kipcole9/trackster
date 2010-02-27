require 'caerus/form_builder'
require 'caerus/form_builder_helper'
require 'caerus/forms_helper'
require 'caerus/theme_helper'
require 'caerus/tabs'
require 'caerus/accordions'
require 'caerus/page_layout'
require 'caerus/lists'
ActionController::Base.helper Caerus::FormBuilderHelper
ActionController::Base.helper Caerus::FormsHelper
ActionController::Base.helper Caerus::Lists
ActionController::Base.helper Caerus::ThemeHelper
ActionController::Base.send(:include, Caerus::ThemeHelper)


