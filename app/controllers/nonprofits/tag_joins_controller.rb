# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class TagJoinsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def index
      render_json do
        {data: QuerySupporters.tag_joins(params["nonprofit_id"], params["supporter_id"])}
      end
    end

    # used for modify a single supporter's tags or a group of
    # selected supporters' tags or all supporters' tags
    def modify
      supporter_ids = if params[:selecting_all]
        QuerySupporters.full_filter_expr(current_nonprofit.id, params[:query]).select("supporters.id").execute.map { |h| h["id"] }
      else
        params[:supporter_ids].map(&:to_i)
      end
      render InsertTagJoins.in_bulk(current_nonprofit.id, current_user.profile.id, supporter_ids, params[:tags])
    end

    def destroy
      supporter = current_nonprofit.supporters.find(params[:supporter_id])
      supporter.tag_joins.find(params[:id]).destroy
      render json: {}, status: :ok
    end
  end
end
