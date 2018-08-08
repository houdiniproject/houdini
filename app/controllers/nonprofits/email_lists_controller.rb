# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
class EmailListsController < ApplicationController
	include Controllers::NonprofitHelper

  before_filter :authenticate_nonprofit_user!

  def index
    render_json{ Qx.fetch(:email_lists, nonprofit_id: params[:nonprofit_id]) }
  end

  def create
    tag_master_ids = params['tag_masters'].values.map(&:to_i)
    render_json{ InsertEmailLists.for_mailchimp(params[:nonprofit_id], tag_master_ids) }
  end
end
end
