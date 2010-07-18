# This plugin is designed primarily to def allow
# the models in the app/models directory to be loaded
#
# The log_analyser itself runs separately an should not
# be loaded by rails
config.gem "file-tail", :lib => false
config.gem "inifile",   :lib => false
config.gem "graticule", :lib => false
config.gem "json",      :lib => false
config.gem 'htmlentities', :lib => false


