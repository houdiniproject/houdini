# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module Nonprofits
  class SupporterEmailsController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def create
      if params[:selecting_all]
        ids = QuerySupporters.full_filter_expr(params[:nonprofit_id], params[:query])
                             .select('supporters.id')
                             .execute(format: 'csv')[1..-1].flatten
      elsif params[:supporter_ids]
        ids = params[:supporter_ids]
      end

      if ids.nil? || ids.empty?
        render json: { errors: 'Supporters not found' }, status: :unprocessable_entity
        return
      end

      render json: { count: ids.count }, status: :ok
    end

    def gmail
      gmail = SupporterEmail.create params[:gmail]
      InsertActivities.for_supporter_emails([gmail.id])
      render json: gmail
    end
  end
end
