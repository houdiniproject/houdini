# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Event::Authorization
  extend ActiveSupport::Concern
  include Controllers::Nonprofit::Authorization

  included do
    private

    def current_event_admin?
      current_nonprofit_admin?
    end

    def current_event_editor?
      !params[:preview] && (
                            current_nonprofit_user? || current_role?(
                              :event_editor,
                              current_event.id
                            ) || current_role?(:super_admin)
                          )
    end

    def authenticate_event_editor!
      return if current_event_editor?

      reject_with_sign_in "You need to be the event organizer or a nonprofit administrator before doing that."
    end
  end
end
