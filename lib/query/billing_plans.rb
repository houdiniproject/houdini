# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'

module BillingPlans

  def self.get_percentage_fee(nonprofit_id)
    ParamValidation.new({nonprofit_id:nonprofit_id}, {nonprofit_id: {:required => true, :is_integer => true}})

    unless (Nonprofit.exists?(nonprofit_id))
      raise ParamValidation::ValidationError.new("#{nonprofit_id} does not exist", {:key => :nonprofit_id} )
    end

    result = Nonprofit.includes(:billing_subscription => :billing_plan)
              .find(nonprofit_id).billing_subscription&.billing_plan&.percentage_fee

    return result || 0
  end

end
