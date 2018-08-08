# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
	class CustomFieldJoinsController < ApplicationController

		include Controllers::NonprofitHelper
		before_filter :authenticate_nonprofit_user!

		def index
			@custom_field_joins = current_nonprofit
				.supporters.find(params[:supporter_id])
				.custom_field_joins
				.order('created_at DESC')
		end

		# used for modify a single supporter's custom fields or a group of 
		# selected supporters' CFs or all supporters' CFs
		def modify
			if params[:custom_fields].blank? || params[:custom_fields].empty?
				render json: {}
				return
			end
			
			if params[:selecting_all]
				supporter_ids = QuerySupporters.full_filter_expr(current_nonprofit.id, params[:query]).select("supporters.id").execute.map{|h| h['id']}
			else
				supporter_ids = params[:supporter_ids]. map(&:to_i)
			end

			render InsertCustomFieldJoins.in_bulk(current_nonprofit.id, supporter_ids, params[:custom_fields])
		end


		def destroy
			supporter = current_nonprofit.supporters.find(params[:supporter_id])
			supporter.custom_field_joins.find(params[:id]).destroy
			render json: {}, status: :ok
		end

	end
end

