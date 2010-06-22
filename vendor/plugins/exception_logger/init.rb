config.after_initialize do
  #$PAGINATION_TYPE = 'none'
  #require 'will_paginate'
  $PAGINATION_TYPE = 'will_paginate'
  #WillPaginate.enable
  #require 'paginating_find'
  #$PAGINATION_TYPE = 'paginating_find'
  require 'logged_exceptions_controller'
  LoggedExceptionsController.view_paths = [File.join(directory, 'views')]
end
