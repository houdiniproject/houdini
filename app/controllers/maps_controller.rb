# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class MapsController < ApplicationController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

  before_action :authenticate_super_associate!, only: :all_supporters
  before_action :authenticate_nonprofit_user!, only: %i[all_npo_supporters specific_npo_supporters]

  # used on admin/nonprofits_map and front page
  def all_npos
    respond_to do |format|
      format.html { redirect_to :root }
      format.json { @map_data = Nonprofit.where('latitude IS NOT NULL').last(1000) }
    end
  end

  # used on admin/supporters_map
  def all_supporters
    @map_data = Supporter.where('latitude IS NOT NULL').last(1000)
  end

  # used on npo dashboard
  def all_npo_supporters
    @map_data = Nonprofit.find(params['npo_id']).supporters.where('latitude IS NOT NULL').last(100)
  end

  # used on supporter dashboard
  def specific_npo_supporters
    supporter_ids = params['supporter_ids'].split(',').map(&:to_i)
    supporters = Nonprofit.find(params['npo_id']).supporters.find(supporter_ids).last(500)
    @map_data =  supporters.map { |s| s if s.latitude != '' }
  end
end
