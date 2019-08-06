# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class EmailListsController < ApplicationController
    include Controllers::NonprofitHelper

    before_action :authenticate_nonprofit_user!

    def index
      render_json { Qx.fetch(:email_lists, nonprofit_id: email_list_params[:nonprofit_id]) }
    end

    def create
      tag_master_ids = email_list_params[:tag_masters].values.map(&:to_i)
      render_json { InsertEmailLists.for_mailchimp(email_list_params[:nonprofit_id], tag_master_ids) }
    end

    private

    def email_list_params
      params.permit(:nonprofit_id, :tag_masters)
    end
  end
end
