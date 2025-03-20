# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RegisterNonprofitForm < ApplicationForm
  attr_accessor :user_attributes, :nonprofit_attributes

  after_save :add_nonprofit_user_mailchimp
  after_save :handle_nonprofit_create_job

  after_validation :cleanup_the_errors

  def initialize(attributes={})
    super(attributes)
    @models = [
      nonprofit_form,
      user_form,
      role,
      billing_subscription,
      stripe_account_form,
    ]
  end

  def billing_plan
    ::BillingPlan.find(Settings.default_bp.id)
  end

  def billing_subscription
    @billing_subscription ||= nonprofit.build_billing_subscription(billing_plan: billing_plan, status: 'active')
  end

  def id
    nonprofit.id
  end

  def nonprofit
    nonprofit_form.nonprofit
  end
  
  def nonprofit_form
    @nonprofit_form ||= NonprofitForm.new(nonprofit_attributes)
  end

  def role
    @role ||= user.roles.build(host: nonprofit, name: 'nonprofit_admin')
  end

  def stripe_account_form
    @stripe_account_form ||= StripeAccountForm.new(nonprofit: nonprofit)
  end

  def user
    user_form.user
  end

  def user_form
    @user_form ||= UserForm.new(user_attributes)
  end

  def add_nonprofit_user_mailchimp
    MailchimpNonprofitUserAddJob.perform_later( user, nonprofit)
  end

  def handle_nonprofit_create_job
    ::Delayed::Job.enqueue ::JobTypes::NonprofitCreateJob.new(nonprofit.id)
  end

  def cleanup_the_errors
    @errors = ActiveModel::Errors.new(self)

    properties = [:nonprofit, :user]
    properties.each do |property_key|
      property = self.send((property_key.to_s + "_form").to_sym)
      property.errors.each do |error|
        errors.import(error, attribute: "#{property_key.to_s}[#{error.attribute}]")
      end
    end
  end
  
end