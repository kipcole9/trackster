module CampaignsHelper
  
  # Show only the email clients that have 10% or more
  # collaps the others into "Other" category
  def collapse_impressions_data(impressions)
    other = 0
    new_impressions = []    
    total_impressions = impressions.sum(:impressions).to_f
    impressions.sort! {|a, b| a.impressions <=> b.impressions}.reverse!
    impressions.each do |i|
      if (i.impressions.to_f / total_impressions) >= 0.05
        new_impressions << i
      else
        other = other + i.impressions
      end
    end
    new_impressions << Track.new(:email_client => I18n.t('reports.other_email_client'), :impressions => other)
  end
  
  def default_concludes_at
    if resource && resource.effective_at
      resource.effective_at + current_account.default_campaign_days.days
    else
      Time.now + current_account.default_campaign_days.days
    end
  end
end
