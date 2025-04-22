# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class CustomFieldJoinsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def index
      @custom_field_joins = current_nonprofit
        .supporters.find(custom_field_params[:supporter_id])
        .custom_field_joins
        .order("created_at DESC")
    end

    # used for modify a single supporter's custom fields or a group of
    # selected supporters' CFs or all supporters' CFs
    def modify
      if custom_field_params[:custom_fields].blank? || custom_field_params[:custom_fields].empty?
        render json: {}
        return
      end

      supporter_ids = if custom_field_params[:selecting_all]
        QuerySupporters.full_filter_expr(current_nonprofit.id, custom_field_params[:query]).select("supporters.id").execute.map { |h| h["id"] }
      else
        custom_field_params[:supporter_ids].map(&:to_i)
      end

      render InsertCustomFieldJoins.in_bulk(current_nonprofit.id, supporter_ids, custom_field_params[:custom_fields])
    end

    def destroy
      supporter = current_nonprofit.supporters.find(custom_field_params[:supporter_id])
      supporter.custom_field_joins.find(custom_field_params[:id]).destroy
      render json: {}, status: :ok
    end

    private

    def custom_field_params
      params.permit(:selecting_all, :supporter_id, :supporter_ids, :custom_fields, :query, :id)
    end
  end
end
