# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class SupporterNotesController < ApplicationController
    include Controllers::NonprofitHelper

    before_action :authenticate_nonprofit_user!, except: [:create]

    # post /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes
    def create
      render json: [Supporter.find(params[:supporter_id]).supporter_notes.create!(create_params.merge(user: current_user))]
    end

    # put /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes/:id
    def update
      params[:supporter_note][:user_id] ||= current_user && current_user.id
      params[:supporter_note][:id] = params[:id]
      render_json { UpdateSupporterNotes.update(params[:supporter_note]) }
    end

    # delete /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes/:id
    def destroy
      render_json { UpdateSupporterNotes.delete(params[:id]) }
    end

    private

    def create_params
      params.require(:supporter_note).permit(:content)
    end
  end
end
