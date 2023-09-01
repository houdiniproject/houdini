# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# A FeeCoverageDetailBase describes the base amount for calculating fee coverage during a fee era.
# Notably, this entity only deals with the amount added from the fee_era itself for Stripe,
# NOT the amount added for Nonprofit's portion of the fees

# @!attribute percentage_fee the percentage to be added for fee coverage during the given fee era
# 	@return [decimal]
# @!attribute flat_fee the amount in cents to be added for fee coverage during the given fee era
# 	@return [integer]
# @!attribute fee_era the fee era that this detail applies to.
# 	@return [FeeEra]
class FeeCoverageDetailBase < ActiveRecord::Base
  belongs_to :fee_era, validate: true
end
