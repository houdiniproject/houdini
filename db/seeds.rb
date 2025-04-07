# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
bp = BillingPlan.new
bp.name = "Default billing plan"
bp.amount = 0
bp.percentage_fee = 0
bp.save!
