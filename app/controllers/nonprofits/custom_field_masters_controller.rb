# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
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
      json_saved CreateCustomFieldMaster.create(current_nonprofit, custom_field_master_params[:custom_field_master])
    end

    def destroy
      current_custom_field_definition.discard!
      current_custom_field_definition.custom_field_joins.destroy_all
      render json: {}, status: :ok
    end

    private

    def custom_field_master_params
      params.require(:custom_field_master).permit( :name)
    end


    def current_custom_field_definition
      current_nonprofit.custom_field_masters.find(params[:id])
    end
  end
end
