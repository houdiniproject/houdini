# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module UpdateDisputes
  def self.disburse_all_with_payments(payment_ids)
    Psql.execute(
      Qexpr.new.update(:disputes, status: "lost_and_paid").where("payment_id IN ($ids)", ids: payment_ids)
    )
  end
end
