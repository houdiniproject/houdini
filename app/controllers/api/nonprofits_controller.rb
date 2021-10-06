# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Api::NonprofitsController < Api::ApiController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    
    before_action :authenticate_nonprofit_user!, only: %i[show]

    # requires :nonprofit, type: Hash do
    #     requires :name, type: String, desc: 'Organization Name', allow_blank: false, documentation: { param_type: 'body' }
    #     requires :zip_code, type: String, allow_blank: false, desc: 'Organization Address ZIP Code', documentation: { param_type: 'body' }
    #     requires :state_code, type: String, allow_blank: false, desc: 'Organization Address State Code', documentation: { param_type: 'body' }
    #     requires :city, type: String, allow_blank: false, desc: 'Organization Address City', documentation: { param_type: 'body' }
    #   end
  
    #   requires :user, type: Hash do
    #     requires :name, type: String, desc: 'Full name', allow_blank: false, documentation: { param_type: 'body' }
    #     requires :email, type: String, desc: 'Username', allow_blank: false, documentation: { param_type: 'body' }
    #     requires :password, type: String, desc: 'Password', allow_blank: false, is_equal_to: :password_confirmation, documentation: { param_type: 'body' }
    def create
        @nonprofit = Nonprofit.new(clean_params.merge({user_id: current_user_id}))
        @nonprofit.save!
        render status: :created
    end

    def show
        @nonprofit = current_nonprofit
    end

    private
    
    def clean_params
        params.permit(:name, :zip_code, :state_code, :city, :phone, :email, :website)
    end

end


