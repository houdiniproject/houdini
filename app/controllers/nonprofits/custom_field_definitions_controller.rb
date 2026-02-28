# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class CustomFieldDefinitionsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def index
      @custom_field_definitions = current_nonprofit
        .custom_field_definitions
        .order("id DESC")
        .not_deleted
    end

    def create
      json_saved CreateCustomFieldDefinition.create(current_nonprofit, custom_field_definition_params)
    end

    def destroy
      current_custom_field_definition.discard!
      current_custom_field_definition.custom_field_joins.destroy_all
      render json: {}, status: :ok
    end

    private

    def custom_field_definition_params
      params.require(:custom_field_definition).permit(:name)
    end

    def current_custom_field_definition
      current_nonprofit.custom_field_definitions.find(params[:id])
    end
  end
end
