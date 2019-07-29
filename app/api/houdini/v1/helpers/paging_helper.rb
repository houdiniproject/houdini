# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::V1::Helpers::PagingHelper
  extend Grape::API::Helpers

  params :pagination do
    optional :page_length, type:Integer, default:20, greater_than_or_equal: 1, less_than_or_equal:100, documentation: { param_type: 'query' }
    optional :page_number, type:Integer, default:0, greater_than_or_equal:0, documentation: { param_type: 'query' }
  end

  def pagify(entity, total)
    entity[:page_length] = declared_params[:page_length]
    entity[:page_number] = declared_params[:page_number]
    entity[:total] = total
    entity
  end
end