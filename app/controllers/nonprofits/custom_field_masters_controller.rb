# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class CustomFieldMastersController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def index
      @custom_field_masters = current_nonprofit
                              .custom_field_masters
                              .order('id DESC')
                              .not_deleted
    end

    def create
      json_saved CreateCustomFieldMaster.create(current_nonprofit, params[:custom_field_master])
    end

    def destroy
      custom_field_master = current_nonprofit.custom_field_masters.find(params[:id])
      custom_field_master.update_attribute(:deleted, true)
      custom_field_master.custom_field_joins.destroy_all
      render json: {}, status: :ok
    end

    private

    def custom_field_master_params
      params.require(:custom_field_master).permit(:nonprofit, :nonprofit_id, :name, :deleted, :created_at)
    end
  end
end
