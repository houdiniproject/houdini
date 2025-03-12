# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::BaseApi < Grape::API
  #helpers ApplicationHelper
  # helpers do
  #   def session
  #     env['rack.session']
  #   end
  #
  #   def protect_against_forgery
  #     unless verified_request?
  #       error!('Unauthorized', 401)
  #     end
  #   end
  #
  #   def verified_request?
  #     !protect_against_forgery? || request.get? || request.head? ||
  #         form_authenticity_token == request.headers['X-CSRF-Token'] ||
  #         form_authenticity_token == request.headers['X-Csrf-Token']
  #   end
  #
  #   def form_authenticity_token
  #     session[:_csrf_token] ||= SecureRandom.base64(32)
  #   end
  #
  #   def protect_against_forgery?
  #     allow_forgery_protection = Rails.configuration.action_controller.allow_forgery_protection
  #     allow_forgery_protection.nil? || allow_forgery_protection
  #   end
  # end
end