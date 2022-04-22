# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class SupportersController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    include Controllers::Supporter::Current

    before_action :authenticate_nonprofit_user!, except: %i[new create]

    # get /nonprofit/:nonprofit_id/supporters
    def index
      @panels_layout = true
      @nonprofit = current_nonprofit
      respond_to do |format|
        format.html
        format.json do
          render json: QuerySupporters.full_search(params[:nonprofit_id], params)
        end

        format.csv do
          file_date = Date.today.strftime('%m-%d-%Y')
          supporters = QuerySupporters.for_export(params[:nonprofit_id], params)
          send_data(Format::Csv.from_vectors(supporters), filename: "supporters-#{file_date}.csv")
        end
      end
    end

    def export
      begin
        @nonprofit = current_nonprofit
        @user = current_user_id
        ExportSupporters.initiate_export(@nonprofit.id, params, @user)
      rescue StandardError => e
        e
      end
      if e.nil?
        flash[:notice] = "Your export was successfully initiated and you'll be emailed at #{current_user.email} as soon as it's available. Feel free to use the site in the meantime."
        render json: {}, status: :ok
      else
        render json: e, status: :ok
      end
    end

    def index_metrics
      render_json do
        QuerySupporters.full_search_metrics(params[:nonprofit_id], params)
      end
    end

    def show
      render json: { data: QuerySupporters.for_crm_profile(params[:nonprofit_id], [params[:id]]).first }
    end

    def email_address
      render json: current_supporter.email
    end

    def full_contact
      begin
        if current_supporter.method_defined? :full_contact_infos && (fc = current_supporter.full_contact_infos.first)
          render json: { full_contact: QueryFullContactInfos.fetch_associated_tables(fc.id) }
        else
          render json: { full_contact: nil }
        end
      rescue
        render json: { full_contact: nil }
      end
    end

    def info_card
      render json: QuerySupporters.for_info_card(params[:supporter_id])
    end

    # post /nonprofits/:nonprofit_id/supporters
    def create
      @supporter = InsertSupporter.create_or_update(current_nonprofit, create_supporter_params.to_h)
    end

    # put /nonprofits/:nonprofit_id/supporters/:id
    def update
      json_saved UpdateSupporter.from_info(current_supporter, update_supporter_params)
    end

    def bulk_delete
      if params[:selecting_all]
        supporter_ids = QuerySupporters.full_filter_expr(current_nonprofit.id, params[:query]).select('supporters.id').execute.map { |h| h['id'] }
      else
        supporter_ids = params[:supporter_ids]. map(&:to_i)
      end
      render_json { UpdateSupporter.bulk_delete(current_nonprofit.id, supporter_ids) }
    end

    # get /nonprofits/:nonprofit_id/supporters/merge_data
    # returns the info required to merge two supporters
    def merge_data
      render json: QuerySupporters.merge_data(params[:ids])
    end

    # post /nonprofits/:nonprofit_id/supporters/merge
    def merge
      render JsonResp.new(params) do |_params|
        requires(:supporter)
        requires(:nonprofit_id).as_int
        requires(:supporter_ids).as_array
      end.when_valid do |params|
        params[:supporter][:nonprofit_id] = params[:nonprofit_id]
        MergeSupporters.selected(update_supporter_params[:supporter], params[:supporter_ids], params[:nonprofit_id], current_user.id)
      end
    end

    private

    def create_supporter_params
      params.require(:supporter).permit(:name, :address, :city, :state_code, :country, :address_line2, :first_name, :last_name, :customFields, :email, :zip_code, :phone)
    end

    def update_supporter_params
      params.require(:supporter).permit(:name, :address, :city, :state_code, :country, :address_line2, :email, :organization, :title, :zip_code, :phone)
    end
  end
end
