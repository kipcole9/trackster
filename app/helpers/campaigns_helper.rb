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
        other =+ i.impressions
      end
    end
    other_impression = impressions.first.dup
    other_impression.browser = "Other"
    other_impression.impressions = other
    new_impressions << other_impression
    new_impressions
  end
end
