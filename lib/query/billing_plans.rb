# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'

module BillingPlans

  def self.get_percentage_fee(nonprofit_id)
    ParamValidation.new({nonprofit_id:nonprofit_id}, {nonprofit_id: {:required => true, :is_integer => true}})

    unless (Nonprofit.exists?(nonprofit_id))
      raise ParamValidation::ValidationError.new("#{nonprofit_id} does not exist", {:key => :nonprofit_id} )
    end

    
    result = Qx.select("billing_plans.percentage_fee")
      .from("billing_plans")
      .join("billing_subscriptions bs", "bs.billing_plan_id = billing_plans.id")
      .where("bs.nonprofit_id=$id", id: nonprofit_id)
      .execute
    return result.empty? ? 0 : result.last['percentage_fee']
  end

end
