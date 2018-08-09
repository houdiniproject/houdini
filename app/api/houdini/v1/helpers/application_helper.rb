# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::V1::Helpers::ApplicationHelper
  extend Grape::API::Helpers


  def session
        env['rack.session']
  end

  def protect_against_forgery
    unless verified_request?
      error!('Unauthorized', 401)
    end
  end

  def verified_request?
    !protect_against_forgery? || request.get? || request.head? ||
        form_authenticity_token == request.headers['X-CSRF-Token'] ||
        form_authenticity_token == request.headers['X-Csrf-Token']
  end

  def form_authenticity_token
    session[:_csrf_token] ||= SecureRandom.base64(32)
  end

  def protect_against_forgery?
    allow_forgery_protection =  Rails.configuration.action_controller.allow_forgery_protection
    allow_forgery_protection.nil? || allow_forgery_protection
  end


  # def rescue_ar_invalid( *class_to_hash)
  #     rescue_with ActiveRecord::RecordInvalid do |error|
  #       output = []
  #       error.record.errors do |attr,message|
  #         output.push({params: "#{class_to_hash[error.record.class]}['#{attr}']",
  #                   message: message})
  #       end
  #       raise Grape::Exceptions::ValidationErrors.new(output)
  #
  #     end
  # end
  #
  #
  def current_role?(role_names, host_id = nil)
    return false unless current_user
    role_names = Array(role_names)
    key = "current_role_user_#{current_user_id}_names_#{role_names.join("_")}_host_#{host_id}"
    QueryRoles.user_has_role?(current_user.id, role_names, host_id)
  end

  def current_user
    @current_user
  end

end

