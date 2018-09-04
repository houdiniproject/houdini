# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::V1::Helpers::EventHelper
  extend Grape::API::Helpers

  # @param [Event] event
  def current_event_admin?(event)
    current_nonprofit_admin?(event.nonprofit)
  end

  # @param [Event] event
  def current_event_editor?(event)
    !params[:preview] && (current_nonprofit_user?(event.nonprofit) || current_role?(:event_editor, event.id) || current_role?(:super_admin))
  end
end

