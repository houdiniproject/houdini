# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module UpdateDisputes
  def self.disburse_all_with_payments(payment_ids)
    Psql.execute(
      Qexpr.new.update(:disputes, status: 'lost_and_paid').where('payment_id IN ($ids)', ids: payment_ids)
    )
  end
end
