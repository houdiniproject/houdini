# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MapsController < ApplicationController
  include Controllers::NonprofitHelper

  before_action :authenticate_super_associate!, only: :all_supporters
  before_action :authenticate_nonprofit_user!, only: [:all_npo_supporters, :specific_npo_supporters]

  # used on admin/nonprofits_map and front page
  def all_npos
    respond_to do |format|
      format.html { redirect_to :root }
      format.json { @map_data = Nonprofit.where.not(latitude: nil).last(1000) }
    end
  end

  # used on admin/supporters_map
  def all_supporters
    @map_data = Supporter.where.not(latitude: nil).last(1000)
  end

  # used on npo dashboard
  def all_npo_supporters
    @map_data = Nonprofit.find(params["npo_id"]).supporters.where.not(latitude: nil).last(100)
  end

  # used on supporter dashboard
  def specific_npo_supporters
    supporter_ids = params["supporter_ids"]&.split(",")&.map { |s| s.to_i } || []
    supporters = Nonprofit.find(params["npo_id"]).supporters.find(supporter_ids).last(500)
    @map_data = supporters.map { |s| s if s.latitude != "" }
  end
end
