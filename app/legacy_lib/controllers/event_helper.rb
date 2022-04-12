# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::EventHelper
	include Controllers::NonprofitHelper

private

	def current_event_admin?
		current_nonprofit_admin?
	end

	def current_event_editor?
		!params[:preview] && (current_nonprofit_user? || current_role?(:event_editor, current_event.id) || current_role?(:super_admin))
	end

	def authenticate_event_editor!
		unless current_event_editor?
			block_with_sign_in 'You need to be the event organizer or a nonprofit administrator before doing that.'
		end
	end

	def current_event
		@event ||= FetchEvent.with_params params, current_nonprofit
		raise ActionController::RoutingError.new "Event not found" if @event.nil?
		return @event
	end

end
