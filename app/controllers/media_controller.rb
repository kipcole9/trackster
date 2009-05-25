class MediaController < ApplicationController
  
  def maxplay
    options = options_from_params(params)
    view_data = Track.video_playtime.label(options[:label]).by(:session).between(options[:period]).all
    round_to_nearest!(view_data, options[:round_to])
    playtimes = views_grouped_by_value(view_data).sort{|a, b| a[:maxplay] <=> b[:maxplay] }
    render :xml => playtimes
  end
  
private
  def options_from_params(params)
    options = {}
    options[:label]     = params[:title] || '0223_quikpro_highlights_700'
    from = options[:from]; to = options[:to]
    options[:period]    = from.to_date..to.to_date if from && to rescue nil
    options[:period]    ||= 1.month.ago..Time.now
    options[:round_to]  = (params[:rounding] || 5).to_i
    options
  end
  
  def views_grouped_by_value(view_data)
    playtimes = []    
    view_data.group_by(&:maxplay).each do |playtime, views|
      playtimes << {:maxplay => playtime.to_i, :count => views.length}
    end
    playtimes
  end
  
  def round_to_nearest!(data, rounding = 5)
    data.each {|d| (d.maxplay = ((d.maxplay.to_i  / rounding).to_i * rounding))}
  end
  
end
