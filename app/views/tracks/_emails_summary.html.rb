panel 'panels.emails_summary' do
  block do
    opened = current_account.sites.first.tracks.opened_emails.by(:campaign_name, :ip_address, :country, :locality)
    clicked = current_account.sites.first.tracks.clicked_emails.by(:campaign_name, :ip_address, :country, :locality)
    store "<p>#{opened.count} visitors opened emails (tracked by IP address) and #{clicked.count} clicked through.</p>"
    store "<p>The email was opened a total of #{opened.sum} times and was clicked through a total of #{clicked.sum} times.</p>"
    store "Thats an average of #{opened.average} openings per visitor and an average of #{clicked.average} click throughs per visitor.</p>"
  end
end
