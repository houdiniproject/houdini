# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module InsertCharge
  # In data, pass in: amount, nonprofit_id, supporter_id, card_id, statement
  # Optionally pass in :metadata for stripe and donation_id to connect to donation?
  # @raise [ParamValidation::ValidationError] parameter validation occurred
  # @raise [Stripe::StripeError] the stripe account couldn't be accessed or created
  def self.with_stripe(data)
    ParamValidation.new(data || {},
                        amount: {
                          required: true,
                          is_integer: true,
                          min: 0
                        },
                        nonprofit_id: {
                          required: true,
                          is_integer: true
                        },
                        supporter_id: {
                          required: true,
                          is_integer: true
                        },
                        card_id: {
                          required: true,
                          is_integer: true
                        },
                        statement: {
                          required: true,
                          not_blank: true
                        })

    np = Nonprofit.where('id = ?', data[:nonprofit_id]).first

    unless np
      raise ParamValidation::ValidationError.new("#{data[:nonprofit_id]} is not a valid Nonprofit", key: :nonprofit_id)
    end

    supporter = Supporter.where('id = ?', data[:supporter_id]).first

    unless supporter
      raise ParamValidation::ValidationError.new("#{data[:supporter_id]} is not a valid Supporter", key: :supporter_id)
    end

    card = Card.where('id = ?', data[:card_id]).first

    unless card
      raise ParamValidation::ValidationError.new("#{data[:card_id]} is not a valid card", key: :card_id)
    end

    unless np == supporter.nonprofit
      raise ParamValidation::ValidationError.new("#{data[:supporter_id]} does not belong to this nonprofit #{np.id}", key: :supporter_id)
    end

    unless card.holder == supporter
      if data[:old_donation]
        # these are not new donations so we let them fly (for now)
      else
        raise ParamValidation::ValidationError.new("#{data[:card_id]} does not belong to this supporter #{supporter.id}", key: :card_id)
      end
    end

    result = {}
    # Catch errors thrown by the stripe gem so we can respond with a 422 with an error message rather than 500
    begin
      stripe_customer_id = card.stripe_customer_id
    rescue StandardError => e
      raise e
    end
    nonprofit_currency = Qx.select(:currency).from(:nonprofits).where('id=$id', id: data[:nonprofit_id]).execute.first['currency']

    stripe_charge_data = {
      customer: stripe_customer_id,
      amount: data[:amount],
      currency: nonprofit_currency,
      description: data[:statement],
      statement_descriptor: data[:statement][0..21].gsub(/[<>"']/, ''),
      metadata: data[:metadata]
    }

    if Houdini.payment_providers.stripe.connect
      stripe_account_id = StripeAccount.find_or_create(data[:nonprofit_id])
      # Get the percentage fee on the nonprofit's billing plan
      platform_fee = BillingPlans.get_percentage_fee(data[:nonprofit_id])
      fee = CalculateFees.for_single_amount(data[:amount], platform_fee)
      stripe_charge_data[:application_fee] = fee

      # For backwards compatibility, see if the customer exists in the primary or the connected account
      # If it's a legacy customer, charge to the primary account and transfer with .destination
      # Otherwise, charge directly to the connected account
      begin
        stripe_cust = Stripe::Customer.retrieve(stripe_customer_id)
        params = [stripe_charge_data.merge(destination: stripe_account_id), {}]
      rescue StandardError
        params = [stripe_charge_data, { stripe_account: stripe_account_id }]
      end
    else
      fee = 0
      stripe_charge_data[:source] = card['stripe_card_id']
      params = [stripe_charge_data, {}]
    end

    begin
      stripe_charge = Stripe::Charge.create(*params)
    rescue Stripe::CardError => e
      failure_message = "There was an error with your card: #{e.json_body[:error][:message]}"
    rescue Stripe::StripeError => e
      failure_message = "We're sorry, but something went wrong. We've been notified about this issue."
    end

    charge = Charge.new

    charge.amount = data[:amount]
    charge.fee = fee

    charge.stripe_charge_id = GetData.chain(stripe_charge, :id)
    charge.failure_message = failure_message
    charge.status = GetData.chain(stripe_charge, :paid) ? 'pending' : 'failed'
    charge.card = card
    charge.donation = Donation.where('id = ?', data[:donation_id]).first
    charge.supporter = supporter
    charge.nonprofit = np
    charge.save!
    result['charge'] = charge

    if stripe_charge && stripe_charge.status != 'failed'
      payment = Payment.new
      payment.gross_amount = data[:amount]
      payment.fee_total = -fee
      payment.net_amount = data[:amount] - fee
      payment.towards = data[:towards]
      payment.kind = data[:kind]
      payment.donation = Donation.where('id = ?', data[:donation_id]).first
      payment.nonprofit = np
      payment.supporter = supporter
      payment.refund_total = 0
      payment.date = data[:date] || result['charge'].created_at
      payment.save!

      result['payment'] = payment

      charge.payment = payment
      charge.save!
      result['charge'] = charge
    end

    result
  rescue StandardError => e
    raise e
  end

  def self.with_sepa(data)
    result = {}
    entities = RetrieveActiveRecordItems.retrieve_from_keys(data, DirectDebitDetail => :direct_debit_detail_id, Supporter => :supporter_id, Nonprofit => :nonprofit_id)
    nonprofit_currency = entities[:nonprofit_id].currency

    # TODO
    fee = 0

    # TODO: charge should be changed to SEPA charge

    c = Charge.new
    c.direct_debit_detail = entities[:direct_debit_detail_id]
    c.amount = data[:amount]
    c.fee = fee
    c.status = 'pending'
    c.nonprofit = entities[:nonprofit_id]
    c.supporter = entities[:supporter_id]
    c.save!

    result['charge'] = c

    p = Payment.new

    p.gross_amount = data[:amount]
    p.fee_total = -fee
    p.net_amount = data[:amount] - fee
    p.towards = data[:towards]
    p.kind = data[:kind]
    p.nonprofit = entities[:nonprofit_id]
    p.supporter = entities[:supporter_id]
    p.refund_total = 0
    p.date = data[:date] || result['charge'].created_at
    p.save!

    result['payment'] = p

    c.payment = p
    c.save!
    p.save!

    result
  end
end
