# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class TagMastersController < ApplicationController
    include Controllers::NonprofitHelper
    before_filter :authenticate_nonprofit_user!

    def index
      render json: {data: 
        Qx.select('id', 'name', 'created_at') 
          .from('tag_masters')
          .where(
            ['tag_masters.nonprofit_id = $id', id: current_nonprofit.id],
            ["coalesce(deleted, FALSE) = FALSE"])
          .execute 
        }
    end

    def create
      json_saved CreateTagMaster.create(current_nonprofit, params[:tag_master])
    end

    def destroy
      tag_master = current_nonprofit.tag_masters.find(params[:id])
      tag_master.update_attribute(:deleted, true)
      tag_master.tag_joins.destroy_all
      render json: {}, status: :ok
    end

  end
end

