# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class TagDefinitionsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    def index
      @tag_definitions = current_nonprofit.tag_definitions.not_deleted
    end

    def create
      json_saved(current_nonprofit.tag_definitions.create(tag_definition_params))
    end

    def destroy
      tag_definition = current_nonprofit.tag_definitions.find(params[:id])
      tag_definition.discard!
      tag_definition.tag_joins.destroy_all
      render json: {}, status: :ok
    end

    private

    def tag_definition_params
      params.require(:tag_definition).permit(:name).tap do |tag_params|
        tag_params.require(:name) # SAFER
      end
    end
  end
end
