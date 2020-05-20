# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class TagMastersController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def index
      render json: { data:
        Qx.select('id', 'name', 'created_at')
          .from('tag_masters')
          .where(
            ['tag_masters.nonprofit_id = $id', id: current_nonprofit.id],
            ['coalesce(deleted, FALSE) = FALSE']
          )
          .execute }
    end

    def create
      json_saved(current_nonprofit.tag_masters.create(tag_master_params[:tag_master]))
    end

    def destroy
      tag_master = current_nonprofit.tag_masters.find(params[:id])
      tag_master.update_attribute(:deleted, true)
      tag_master.tag_joins.destroy_all
      render json: {}, status: :ok
    end

    private

    def tag_master_params
      params.require(:tag_master).permit(:name).tap do |tag_params|
        tag_params.require(:name) # SAFER
      end
    end
  end
end
