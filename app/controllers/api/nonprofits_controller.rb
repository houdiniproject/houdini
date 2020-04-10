class Api::NonprofitsController < ApplicationController
    
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
        model = CreateModel.new(clean_params)
        np = nil
        u = nil
        raise ActiveRecord::RecordInvalid
        Qx.transaction do
          raise Errors::MessageInvalid.new(model) unless model.valid?
          model.save!
        end
        # Qx.transaction do
        #   byebug
        #   np = ::Nonprofit.new(OnboardAccounts.set_nonprofit_defaults(clean_params[:nonprofit]))
    
        #   begin
        #     np.save!
        #   rescue ActiveRecord::RecordInvalid => e
        #     if e.record.errors[:slug]
        #       begin
        #         slug = SlugNonprofitNamingAlgorithm.new(np.state_code_slug, np.city_slug).create_copy_name(np.slug)
        #         np.slug = slug
        #         np.save!
        #       rescue UnableToCreateNameCopyError
        #         raise Grape::Exceptions::ValidationErrors.new(errors: [Grape::Exceptions::Validation.new(
        #           params: ['nonprofit[name]'],
        #           message: 'has an invalid slug. Contact support for help.'
        #         )])
        #       end
        #     else
        #       raise e
        #     end
        #   end
    
        #   u = User.new(clean_params[:user])
        #   u.save!
    
        #   role = u.roles.build(host: np, name: 'nonprofit_admin')
        #   role.save!
    
        #   billing_plan = BillingPlan.find(Settings.default_bp.id)
        #   b_sub = np.build_billing_subscription(billing_plan: billing_plan, status: 'active')
        #   b_sub.save!
        # rescue ActiveRecord::RecordInvalid => e
        #   class_to_name = { Nonprofit => 'nonprofit', User => 'user' }
        #   if class_to_name[e.record.class]
        #     errors = e.record.errors.keys.map do |k|
        #       errors = e.record.errors[k].uniq
        #       errors.map do |error|
        #         Grape::Exceptions::Validation.new(
        #           params: ["#{class_to_name[e.record.class]}[#{k}]"],
        #           message: error
        #         )
        #       end
        #     end
    
        #     raise Grape::Exceptions::ValidationErrors.new(errors: errors.flatten)
        #   else
        #     raise e
        #   end
        # end
    end

    def clean_params
        params.permit(nonprofit: [:name, :zip_code, :state_code, :city], user: [:name, :email, :password])
    end

end


