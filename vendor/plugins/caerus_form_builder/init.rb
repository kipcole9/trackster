require 'caerus_form_builder'
require 'caerus_form_builder_helper'
require 'caerus_forms_helper'
require 'theme_helper'
ActionController::Base.helper CaerusFormBuilderHelper
ActionController::Base.helper CaerusFormsHelper
ActionController::Base.helper ThemeHelper
ActionController::Base.send(:include, ThemeHelper)


