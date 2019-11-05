# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class SupporterNotesController < ApplicationController
    include Controllers::NonprofitHelper

    before_action :authenticate_nonprofit_user!, except: [:create]

    # post /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes
    def create
      params[:supporter_note][:user_id] ||= current_user&.id
      render_json { InsertSupporterNotes.create([supporter_params[:supporter_note]]) }
    end

    # put /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes/:id
    def update
      params[:supporter_note][:user_id] ||= current_user&.id
      params[:supporter_note][:id] = params[:id]
      render_json { UpdateSupporterNotes.update(supporter_params[:supporter_note]) }
    end

    # delete /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes/:id
    def destroy
      render_json { UpdateSupporterNotes.delete(params[:id]) }
    end

    private
    
    def supporter_params
      params.require(:supporter_note)

    end
    end
end
