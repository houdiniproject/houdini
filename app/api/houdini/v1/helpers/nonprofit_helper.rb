# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::V1::Helpers::NonprofitHelper
  extend Grape::API::Helpers


  # @param [Nonprofit] nonprofit
  def current_nonprofit_user?(nonprofit)
    @current_user_role ||= current_role?([:nonprofit_admin, :nonprofit_associate], nonprofit.id) || current_role?(:super_admin)
  end

  # @param [Nonprofit] nonprofit
  def current_nonprofit_admin?(nonprofit)
    return false if !current_user || current_user.roles.empty?
    @current_admin_role ||= current_role?(:nonprofit_admin, nonprofit.id) || current_role?(:super_admin)
  end

end

