with_tag :div, :class => "grid_12" do
  main_menu do
    menu_item 'Dashboard', :href => dashboard_path
    menu_item "Web Properties" do
      menu_item "Define a new web property",  :href => new_property_path if permitted_to? :create, :properties
      menu_item "Show all web properties",    :href => properties_path
    end
    menu_item "Campaigns" do
      menu_item "Create a new campaign",  :href => new_campaign_path if permitted_to? :create, :campaigns
      menu_item "Show all campaigns",     :href => campaigns_path
    end
    menu_item "Contacts" do
      menu_item "Create a new contact",   :href => new_contact_path if permitted_to? :create, :contacts
      menu_item "Show all contacts",      :href => contacts_path
    end
    menu_item "Account" do
      menu_item "Edit your account",    :href => edit_account_path(current_account) if permitted_to? :edit, current_account
      menu_item "Show account users",   :href => users_path
      menu_item "Create a new user",    :href => new_user_path    if permitted_to? :create, :users
      menu_item "Show all accounts",    :href => accounts_path
      menu_item "Create a new account", :href => new_account_path if permitted_to? :create, :accounts
    end
    menu_item "Site" do
      menu_item "Site performance", :href => site_path
    end
  end
end