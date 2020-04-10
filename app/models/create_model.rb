class CreateModel < Base
    attr_accessor :nonprofit, :user
    validates_presence_of :user
    validates_presence_of :nonprofit
    validate_nested_attribute :user, model_class: User
    validate_nested_attribute :nonprofit, model_class: Nonprofit
    
    before_validation do
        nonprofit = Nonprofit.create(nonprofit) if !nonprofit.is_a? Nonprofit
        user = User.create(user) if !nonprofit.is_a? Nonprofit
    end
    
    def save
        if valid?
            if nonprofit.save!
                if user.save!
                    role = user.roles.build(host: nonprofit, name: 'nonprofit_admin')
                    role.save!

                    billing_plan = BillingPlan.find(Settings.default_bp.id)
                    b_sub = nonprofit.build_billing_subscription(billing_plan: billing_plan, status: 'active')
                    b_sub.save!
                end
            end
        end
        # rescue ActiveRecord::RecordInvalid => e
        #     class_to_name = { Nonprofit => 'nonprofit', User => 'user' }
        #     if class_to_name[e.record.class]
        #     errors = e.record.errors.keys.map do |k|
        #         errors = e.record.errors[k].uniq
        #         errors.map do |error|
        #         Grape::Exceptions::Validation.new(
        #             params: ["#{class_to_name[e.record.class]}[#{k}]"],
        #      value       message: error
        #         )
        #         end
        #     end
        #         raise Grape::Exceptions::ValidationErrors.new(errors: errors.flatten)
        #     else
        #         raise e
        #     end
        # end
    end

    def save!
        raise 'runtime' unless save
    end
end