with_tag :div, :class => "grid_12", :id => 'menu' do
  main_menu do
    menu_item t('menu.dashboard'),                  :href => dashboard_path
    menu_item t('menu.web_properties') do
      menu_item t('menu.property.define'),          :href => new_property_path  if can? :create, Property
      menu_item t('menu.property.index'),           :href => properties_path
    end
    menu_item t('menu.campaigns') do
      menu_item t('menu.campaign.define'),          :href => new_campaign_path  if can? :create, Campaign
      menu_item t('menu.campaign.index'),           :href => campaigns_path
    end
    menu_item t('menu.contents') do
      menu_item t('menu.content.define'),           :href => new_content_path   if can? :create, Content           
      menu_item t('menu.content.index'),            :href => contents_path
    end
    menu_item t('menu.contacts') do
      menu_item t('menu.contact.define'),           :href => new_person_path    if can? :create, Contact
      menu_item t('menu.contact.people'),           :href => people_path
      menu_item t('menu.contact.organizations'),    :href => organizations_path            
      menu_item t('menu.contact.index'),            :href => contacts_path
    end
    menu_item t('menu.accounts') do
      menu_item t('menu.account.edit'),             :href => edit_account_path(current_account) if can? :edit, current_account
      menu_item t('menu.account.users'),            :href => users_path         if can? :read,   User 
      menu_item t('menu.account.user.define'),      :href => new_user_path      if can? :create, User
      menu_item t('menu.account.index'),            :href => accounts_path      if can? :read,   Account
      menu_item t('menu.account.define'),           :href => new_account_path   if can?(:create, Account) && !current_account.client_account?
    end if can?(:read, User) || can?(:read, Account)
    menu_item t('menu.sites') do
      menu_item t('menu.site.performance'),         :href => site_path
    end if current_user.admin?
    menu_item (print_button),                       {}, {:class => :secondary }
    menu_item t('menu.logout'),                     {:href => logout_path}, :class => :secondary
    menu_item t('menu.profile'),                    {:href => edit_user_path(current_user)}, :class => :secondary             
    menu_item t('menu.accounts_list'), {}, {:class => :secondary } do
      current_user.accounts.each do |account|
        menu_item  account.name,                    {:href => "http://#{account.subdomain}.#{Trackster::Config.host}"}
      end  
    end if current_user.accounts.size > 1
  end
end
clear

