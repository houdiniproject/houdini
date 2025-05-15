# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchNonprofit
  def self.with_params(params, administered_nonprofit = nil)
    if params[:state_code] && params[:city] && params[:name]
      Nonprofit.find_via_cached_key_for_location(params[:state_code], params[:city], params[:name])
    elsif params[:nonprofit_id] || params[:id]
      Nonprofit.find_via_cached_id(params[:nonprofit_id] || params[:id])
    elsif administered_nonprofit
      administered_nonprofit
    end
  end
end
