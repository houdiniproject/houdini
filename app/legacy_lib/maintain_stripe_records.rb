module MaintainStripeRecords
  def self.safely_fill_stripe_charge_object(stripe_charge_id)
    LockManager.with_transaction_lock(stripe_charge_id) do
      unless StripeCharge.where("stripe_charge_id = ?", stripe_charge_id).any?
        object = Stripe::Charge.retrieve(stripe_charge_id)
        StripeCharge.create!(object: object)
      end
    end
  end
end
