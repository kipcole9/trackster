panel 'panels.emails_clicked' do
  block do
    store current_account.sites.first.tracks.clicked_emails.by(:campaign_name, :ip_address, :country, :locality).to_table
  end
end
