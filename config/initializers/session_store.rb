# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_trackster_session',
  :secret      => 'a2b637ac383ad085a1775e5b013e9078922ccb6503f31c2abe693ddd693254e2d24141a508a9de6fa064486bddd02feb1cbeafe3817971c3c49437143f4cf89c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
