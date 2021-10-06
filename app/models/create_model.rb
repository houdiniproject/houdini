
  class CustomAssociatedValidator < ActiveModel::EachValidator #:nodoc:
    def validate_each(record, attribute, value)
        byebug
      if Array(value).reject { |r| valid_object?(r) }.any?
        record.errors.add(attribute, :invalid, **options.merge(value: value))
      end
    end

    private
      def valid_object?(record)
         record.valid?
      end
  end

class CreateModel < Base
    attr_accessor :nonprofit, :user
    validates_presence_of :user
    validates_presence_of :nonprofit
    #validate_nested_attribute :user, model_class: User
   # validate_nested_attribute :nonprofit, model_class: Nonprofit
    validates_with CustomAssociatedValidator, attributes: [:nonprofit]
    
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

                    billing_plan = BillingPlan.find(Houdini.default_bp.id)
                    b_sub = nonprofit.build_billing_subscription(billing_plan: billing_plan, status: 'active')
                    b_sub.save!
                end
            end
        end
    end

    def save!
        raise 'runtime' unless save
    end
  
end

