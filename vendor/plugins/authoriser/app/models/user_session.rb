class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages true
  single_access_allowed_request_types :all
  params_key "api_key"
  
end