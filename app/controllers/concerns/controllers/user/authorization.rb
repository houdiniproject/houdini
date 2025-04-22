# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::User::Authorization
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Layout/LineLength
  included do
    helper_method :current_role?, :administered_nonprofit

    protected

    def authenticate_user!
      reject_with_sign_in unless current_user
    end

    def reject_with_sign_in(msg = nil)
      respond_to do |format|
        format.json { raise AuthenticationError }
        format.any { block_with_sign_in(msg) }
      end
    end

    def block_with_sign_in(msg = nil)
      if current_user
        redirect_to root_path(redirect_url: request.fullpath)
      else
        redirect_to new_user_session_path(redirect_url: request.fullpath), flash: {error: msg}
      end
    end

    def current_role?(role_names, host_id = nil)
      return false unless current_user

      role_names = Array(role_names)
      QueryRoles.user_has_role?(current_user.id, role_names, host_id)
    end

    def authenticate_confirmed_user!(msg = nil)
      if !current_user
        reject_with_sign_in(msg)
      elsif !current_user.confirmed? && !current_role?(%i[super_associate super_admin])
        respond_to do |format|
          format.json {	raise AuthenticationError }
          format.any { redirect_to new_user_confirmation_path, flash: {error: "You need to confirm your account to do that."} }
        end
      end
    end

    def authenticate_super_associate!
      reject_with_sign_in "Please login." unless current_role?(:super_admin) || current_role?(:super_associate)
    end

    def authenticate_super_admin!
      reject_with_sign_in "Please login." unless current_role?(:super_admin)
    end

    def store_location
      referrer = request.fullpath
      no_redirects = ["/users", "/signup", "/signin", "/users/sign_in", "/users/sign_up", "/users/password",
        "/users/sign_out", /.*\.json.*/, %r{.*auth/facebook.*}]

      return if request.format.symbol == :json || no_redirects.map { |p| referrer.match(p) }.any?

      session[:previous_url] = referrer
    end

    def administered_nonprofit
      return nil unless current_user

      ::Nonprofit.where(id: QueryRoles.host_ids(current_user_id, %i[nonprofit_admin nonprofit_associate])).last
    end

    def current_user_id
      current_user&.id
    end
  end
end

# rubocop:enable all
