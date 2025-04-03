# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Nonprofit < Houdini::V1::BaseApi
   helpers Houdini::V1::Helpers::ApplicationHelper, Houdini::V1::Helpers::RescueHelper

   before do
   end

  desc 'Return a nonprofit.' do
    success Houdini::V1::Entities::Nonprofit
  end
  params do
    requires :id, type: Integer, desc: 'Status id.'
  end
  route_param :id do
    get do
      np = Nonprofit.find(params[:id])
      present np, as: Houdini::V1::Entities::Nonprofit
    end
  end
   
  desc 'Register a nonprofit' do
    success Houdini::V1::Entities::Nonprofit

    #this needs to be a validation an array
    failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors}]
  end

  params do

    requires :nonprofit, type: Hash  do
      requires :name, type:String, desc: 'Organization Name', allow_blank: false, documentation: { param_type: 'body' }
      optional :website, type:String, desc: 'Organization website URL', allow_blank:true, regexp: URI::regexp, documentation: { param_type: 'body' }, coerce_with: ->(url) {
        coerced_url = url
        unless (url =~ /\Ahttp:\/\/.*/i || url =~ /\Ahttps:\/\/.*/i)
          coerced_url = 'http://'+ coerced_url
        end
        coerced_url
      }
      requires :zip_code, type:String, allow_blank: false, desc: "Organization Address ZIP Code", documentation: { param_type: 'body' }
      requires :state_code, type:String, allow_blank: false, desc: "Organization Address State Code", documentation: { param_type: 'body' }
      requires :city, type:String, allow_blank: false, desc: "Organization Address City", documentation: { param_type: 'body' }
      optional :email, type:String, desc: 'Organization email (public)', regexp: Email::Regex, documentation: { param_type: 'body' }
      optional :phone, type:String, desc: 'Organization phone (public)', documentation: { param_type: 'body' }
    end

    requires :user, type: Hash do
      requires :name, type:String, desc: 'Full name', allow_blank:false, documentation: { param_type: 'body' }
      requires :email, type:String, desc: 'Username', allow_blank: false, documentation: { param_type: 'body' }
      requires :password, type:String, desc: 'Password', allow_blank: false, is_equal_to: :password_confirmation, documentation: { param_type: 'body' }
      requires :password_confirmation, type:String, desc: 'Password confirmation', allow_blank: false, documentation: { param_type: 'body' }
    end


  end
  post do
    declared_params = declared(params)
    np = nil
    u = nil
    Qx.transaction do
      begin
        np = ::Nonprofit.new(OnboardAccounts.set_nonprofit_defaults(declared_params[:nonprofit]))

        begin
          np.save!
        rescue ActiveRecord::RecordInvalid => e
          if (e.record.errors[:slug])
            begin
              slug = ::SlugNonprofitNamingAlgorithm.new(np.state_code_slug, np.city_slug).create_copy_name(np.slug)
              np.slug = slug
              np.save!
            rescue UnableToCreateNameCopyError
              raise Grape::Exceptions::ValidationErrors.new(errors:[Grape::Exceptions::Validation.new(

                  params: ["nonprofit[name]"],
                  message: "has an invalid slug. Contact support for help."
              )])
            end
          else
            raise e
          end
        end

        u = ::User.new(declared_params[:user])
        u.save!

        role = u.roles.build(host: np, name: 'nonprofit_admin')
        role.save!
        
        MailchimpNonprofitUserAddJob.perform_later( u, np)
        
        billing_plan = ::BillingPlan.find(Settings.default_bp.id)
        b_sub = np.build_billing_subscription(billing_plan: billing_plan, status: 'active')
        b_sub.save!
        ::StripeAccountUtils.find_or_create(np.id)
        np.reload

        ::Delayed::Job.enqueue ::JobTypes::NonprofitCreateJob.new(np.id)
      rescue ActiveRecord::RecordInvalid => e
        class_to_name = {Nonprofit => 'nonprofit', User => 'user'}
        if class_to_name[e.record.class]
          errors = e.record.errors.keys.map {|k|

            errors = e.record.errors[k].uniq
            errors.map{|error| Grape::Exceptions::Validation.new(

                params: ["#{class_to_name[e.record.class]}[#{k.to_s}]"],
                message: error

            )}
          }

          raise Grape::Exceptions::ValidationErrors.new(errors:errors.flatten)
        else
          raise e
        end

      end
    end
    #onboard callback
    present np, with: Houdini::V1::Entities::Nonprofit
  end



end