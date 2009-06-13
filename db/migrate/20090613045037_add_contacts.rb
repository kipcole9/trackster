class AddContacts < ActiveRecord::Migration
  def self.up
    create_table "addresses", :force => true do |t|
      t.integer  "contact_id"
      t.string   "street"
      t.string   "locality"
      t.string   "country"
      t.string   "postalcode", :limit => 10
      t.string   "kind",       :limit => 10
      t.string   "region"
      t.boolean  "preferred",                :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "addresses", ["contact_id"], :name => "index_addresses_on_contact_id"

    create_table "affiliations", :force => true do |t|
      t.integer "contact_id"
      t.string  "type",         :limit => 10
      t.integer "affiliate_id"
    end

    add_index "affiliations", ["affiliate_id"], :name => "index_affiliations_on_affiliate_id"
    add_index "affiliations", ["contact_id"], :name => "index_affiliations_on_contact_id"

    create_table "comments", :force => true do |t|
      t.string   "title",            :default => ""
      t.text     "comment"
      t.integer  "commentable_id"
      t.string   "commentable_type"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
    add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
    add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

    create_table "contacts", :force => true do |t|
      t.string   "given_name"
      t.string   "family_name"
      t.string   "salutation",         :limit => 30
      t.string   "nickname",           :limit => 20
      t.string   "name",               :limit => 100
      t.string   "locale",             :limit => 50
      t.string   "timezone",           :limit => 50
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id"
      t.string   "role"
      t.string   "profile"
      t.string   "photo_file_name"
      t.string   "photo_content_type"
      t.integer  "photo_file_size"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.integer  "organization_id"
      t.string   "gender",             :limit => 10,  :default => "unknown"
      t.string   "role_function",      :limit => 50
      t.string   "role_level",         :limit => 50
      t.string   "name_order",         :limit => 2
      t.string   "honorific_prefix",   :limit => 50
      t.string   "honorific_suffix",   :limit => 50
      t.string   "type"
      t.integer  "employees"
      t.integer  "revenue"
    end

    add_index "contacts", ["family_name"], :name => "index_contacts_on_family_name"
    add_index "contacts", ["given_name"], :name => "index_contacts_on_given_name"
    add_index "contacts", ["name"], :name => "index_contacts_on_name"

    create_table "emails", :force => true do |t|
      t.integer  "contact_id"
      t.string   "address"
      t.string   "kind",       :limit => 10
      t.boolean  "preferred",                :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "emails", ["contact_id"], :name => "index_emails_on_contact_id"

    create_table "files", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "group_members", :force => true do |t|
      t.integer  "group_id"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "groups", :force => true do |t|
      t.string   "name"
      t.string   "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id"
    end

    create_table "histories", :force => true do |t|
      t.text     "updates"
      t.integer  "created_by"
      t.string   "historical_type"
      t.integer  "historical_id"
      t.string   "transaction"
      t.datetime "created_at"
      t.string   "actionable_type", :limit => 20
      t.integer  "actionable_id"
    end

    create_table "instant_messengers", :force => true do |t|
      t.integer "contact_id"
      t.string  "type",       :limit => 10
      t.string  "address"
      t.boolean "preferred",                :default => false
    end

    add_index "instant_messengers", ["contact_id"], :name => "index_instant_messengers_on_contact_id"

    create_table "notes", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "note"
      t.string   "notable_type", :limit => 20
      t.integer  "notable_id"
      t.integer  "updated_by"
      t.integer  "created_by"
      t.date     "related_date"
    end

    create_table "phones", :force => true do |t|
      t.integer  "contact_id"
      t.string   "kind",       :limit => 10
      t.string   "number",     :limit => 50
      t.boolean  "preferred",                :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "phones", ["contact_id"], :name => "index_phones_on_contact_id"

    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "taggable_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

    create_table "tags", :force => true do |t|
      t.string "name"
    end

    create_table "team_members", :force => true do |t|
      t.integer  "user_id"
      t.integer  "team_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "teams", :force => true do |t|
      t.integer  "account_id"
      t.string   "name"
      t.text     "description"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "parent_id"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
