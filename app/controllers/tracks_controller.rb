class TracksController < ApplicationController
  VALID_PARAMETERS      = :by, :from, :to, :metric, :site
  before_filter         :retrieve_tracks, :only => [:index]
  
private
  def retrieve_tracks
    scope = params.dup
    scope.delete_if {|k, v| !VALID_PARAMETERS.include?(k.to_sym)}
    scope[:between] = scope[:from].to_date..scope[:to].to_date if scope[:from] && scope[:to]
    scope[:by] = scope[:by].split(',').map(&:strip) if scope[:by]
    raise ArgumentError, 
        "Unknown metric requested: #{scope[:metric]}" unless Track.available_metrics.include?(scope[:metric])
    site = current_account.sites.first
    @tracks = eval "site.tracks.#{scope[:metric]}.between(scope[:between]).by(scope[:by])"
  end
end
