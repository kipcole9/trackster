panel 'panels.emails_opened' do
  block do
    store current_account.sites.first.tracks.opened_emails.by(:campaign_name, :ip_address, :country, :locality).to_table
  end
end
