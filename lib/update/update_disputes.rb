
module UpdateDisputes

  def self.disburse_all_with_payments(payment_ids)
    Psql.execute(
      Qexpr.new.update(:disputes, {status: 'lost_and_paid'}).where("payment_id IN ($ids)", ids: payment_ids)
    )
  end
end
