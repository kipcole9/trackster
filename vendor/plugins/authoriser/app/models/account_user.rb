class AccountUser < ActiveRecord::Base
  unloadable
  belongs_to  :user
  belongs_to  :account
  belongs_to  :role
end
