class AccountUser < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :account
  belongs_to  :role
end
