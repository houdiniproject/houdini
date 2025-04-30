# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Nonprofit::Authorization
  extend ActiveSupport::Concern
  include Controllers::User::Authorization

  included do
    helper_method :current_nonprofit_user?

    private

    def authenticate_nonprofit_user!
      reject_with_sign_in unless current_nonprofit_user?
    end

    def authenticate_nonprofit_admin!
      reject_with_sign_in unless current_nonprofit_admin?
    end

    def current_nonprofit_user?
      return false if params[:preview]
      return false unless current_nonprofit_without_exception

      @current_nonprofit_user ||= current_role?(
        %i[nonprofit_admin nonprofit_associate],
        current_nonprofit_without_exception.id
      ) || current_role?(:super_admin)
    end

    def current_nonprofit_admin?
      return false if !current_user || current_user.roles.empty?

      @current_nonprofit_admin ||= current_role?(:nonprofit_admin, current_nonprofit.id) || current_role?(:super_admin)
    end
  end
end
