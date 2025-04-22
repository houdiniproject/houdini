# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class EmailListsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!

    def index
      render_json { Qx.fetch(:email_lists, nonprofit_id: email_list_params[:nonprofit_id]) }
    end

    def create
      tag_definition_ids = email_list_params[:tag_definitions].values.map(&:to_i)
      render_json { InsertEmailLists.for_mailchimp(email_list_params[:nonprofit_id], tag_definition_ids) }
    end

    private

    def email_list_params
      params.permit(:nonprofit_id, :tag_definitions)
    end
  end
end
