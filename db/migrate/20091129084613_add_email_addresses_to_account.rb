class AddEmailAddressesToAccount < ActiveRecord::Migration
  def self.up
    # Define default addresses for email campaigns.
    [:accounts, :campaigns].each do |r|
      add_column r, :email_from, :string,           :limit => 50
      add_column r, :email_from_name, :string,      :limit => 50
      add_column r, :email_reply_to, :string,       :limit => 50
      add_column r, :email_reply_to_name, :string,  :limit => 50
      add_column r, :unsubscribe_url, :string
    end
  end

  def self.down
    [:accounts, :campaigns].each do |r|
      remove_column r, :email_from
      remove_column r, :email_from_name
      remove_column r, :email_reply_to
      remove_column r, :email_reply_to_name
      remove_column r, :unsubscribe_url
    end    
  end
end
