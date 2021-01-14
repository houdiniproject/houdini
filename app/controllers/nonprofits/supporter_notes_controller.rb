# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

class Nonprofits::SupporterNotesController < ApplicationController
  include Controllers::Supporter::Current
  include Controllers::Nonprofit::Authorization

  before_action :authenticate_nonprofit_user!, except: [:create]

  # post /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes
  def create
    render_json { InsertSupporterNotes.create(supporter_params[:supporter_note]) }
  end

  # put /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes/:id
  def update
    render_json { UpdateSupporterNotes.update(current_supporter_note,
      supporter_params[:supporter_note].merge({user_id: current_user&.id})) }
  end

  # delete /nonprofits/:nonprofit_id/supporters/:supporter_id/supporter_notes/:id
  def destroy
    render_json { UpdateSupporterNotes.delete(current_supporter_note) }
  end

  private
  
  def current_supporter_note
    current_supporter.supporter_notes.includes(:activities).find(params[:id])
  end

  def supporter_params
    params.require(:supporter_note).require(:content)
  end
end
