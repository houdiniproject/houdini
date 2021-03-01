# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module Controllers::User::Authorization
	extend ActiveSupport::Concern

	# rubocop:disable Metrics/BlockLength
	# rubocop:disable Layout/LineLength
	included do
		helper_method :current_role?, :administered_nonprofit

		protected

		def authenticate_user_with_json!
			reject_with_sign_in({}, :json) unless current_user
		end

		def authenticate_user!(msg = nil, type = :html)
			reject_with_sign_in(msg, type) unless current_user
		end

		def reject_with_sign_in(msg = nil, type = :html)
			if type == :html
				block_with_sign_in(msg)
			else
				render json: { message: msg }, status: :unauthorized
			end
		end

		def block_with_sign_in(msg = nil)
			store_location
			if current_user
				flash[:notice] =
					"It looks like you're not allowed to access that page. If this seems like a mistake, please contact #{Houdini.support_email}"
				redirect_to root_path
			else
				msg ||= 'We need to sign you in before you can do that.'
				redirect_to new_user_session_path, flash: { error: msg }
			end
		end

		def current_role?(role_names, host_id = nil)
			return false unless current_user

			role_names = Array(role_names)
			QueryRoles.user_has_role?(current_user.id, role_names, host_id)
		end

		def authenticate_confirmed_user!(msg = nil, type = :html)
			if !current_user
				reject_with_sign_in(msg, type)
			elsif !current_user.confirmed? && !current_role?(%i[super_associate super_admin])
				if type == :html
					redirect_to new_user_confirmation_path, flash: { error: 'You need to confirm your account to do that.' }
				else
					render json: { message: msg }, status: :unauthorized
				end
			end
		end

		def authenticate_super_associate!
			reject_with_sign_in 'Please login.' unless current_role?(:super_admin) || current_role?(:super_associate)
		end

		def authenticate_super_admin!
			reject_with_sign_in 'Please login.' unless current_role?(:super_admin)
		end

		def store_location
			referrer = request.fullpath
			no_redirects = ['/users', '/signup', '/signin', '/users/sign_in', '/users/sign_up', '/users/password',
																			'/users/sign_out', /.*\.json.*/, %r{.*auth/facebook.*}]

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
