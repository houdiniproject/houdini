# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class SupporterEmailsController < ApplicationController
    include Controllers::NonprofitHelper
    before_filter :authenticate_nonprofit_user!

    def create
      if params[:selecting_all]
        ids = QuerySupporters.full_filter_expr(params[:nonprofit_id], params[:query])
          .select("supporters.id")
          .execute(format: 'csv')[1..-1].flatten
      elsif params[:supporter_ids]
        ids = params[:supporter_ids]
      end

      if ids.nil? || ids.empty?
        render json: {errors: 'Supporters not found'}, status: :unprocessable_entity
        return
      end

      DelayedJobHelper.enqueue_job(EmailSupporters, :deliver, [ids, params[:supporter_email]])
      render json: {count: ids.count}, status: :ok 
    end

    def gmail
      gmail = SupporterEmail.create params[:gmail]
      InsertActivities.for_supporter_emails([gmail.id])
      render json: gmail
    end
  end
end

