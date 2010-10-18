class AddContentIdToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :content_id, :integer
    Session.find_each do |s|
      next unless s.campaign_content
      account = s.account
      s.content = account.contents.find_by_id(s.campaign_content) || account.contents.find_by_code(s.campaign_content)
      s.save
    end
  end

  def self.down
    remove_column :sessions, :content_id
  end
end
