require 'devise'

module GrapeDevise::API
  extend ActiveSupport::Concern
  include Devise::Controllers::SignInOut
  
  def self.define_helpers mapping
    mapping = mapping.name.to_s

    class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def warden
            env["warden"]
          end

          def authenticate_#{mapping}!(opts={})
            opts[:scope] = :#{mapping}
            env["devise.allow_params_authentication"] = true
            if opts.delete(:force) || current_#{mapping}.nil?
              error!("401 Forbidden", 401) unless warden.authenticate(opts)
            end
          end

          def #{mapping}_signed_in?
            !!current_#{mapping}
          end

          def current_#{mapping}
            @current_#{mapping} ||= warden.authenticate(scope: :#{mapping})
          end

          def #{mapping}_session
            current_#{mapping} && warden.session(:#{mapping})
          end
    METHODS
  end

end
