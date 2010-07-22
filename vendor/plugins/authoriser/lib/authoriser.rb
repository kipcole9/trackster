# Authoriser Exceptions
module Activation
  class CodeNotFound < Exception; end
  class UserAlreadyActive < Exception; end
end
