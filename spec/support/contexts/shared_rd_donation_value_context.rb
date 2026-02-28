# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# holy cow, this is confusing
RSpec.shared_context :shared_rd_donation_value_context do
  include_context :shared_donation_charge_context

  let(:fake_uuid) { "53a6bc06-0789-11e8-bb3f-f34cac607737" }
  let(:valid_uuid) { "fcf61bac-078a-11e8-aa53-cba5bdb8dcdd" }
  let(:other_uuid) { "a713018c-078f-11e8-ae3b-bf5007844fea" }
  let(:source_token) { force_create(:source_token, tokenizable: card, expiration: Time.now + 1.day, max_uses: 1, token: valid_uuid) }
  let(:source_tokens) do
    (0..10).map do |_i|
      force_create(:source_token, tokenizable: card, expiration: Time.now + 1.day, max_uses: 1, token: SecureRandom.uuid)
    end
  end

  let(:other_source_token) { force_create(:source_token, tokenizable: card_for_other_supporter, expiration: Time.now + 1.day, max_uses: 1, token: other_uuid) }

  let(:charge_amount) { 100 }

  let(:default_edit_token) { "7903e34c-10fe-11e8-9ead-d302c690bee4" }
  before do
  end

  def generate_expected(donation_id, payment_id, charge_id, card, supporter, nonprofit, stripe_charge_id, data = {})
    payment_stuff = {}
    payment_stuff[:card_id] = card.id if card.is_a? Card
    payment_stuff[:direct_debit_detail_id] = card.id if card.is_a? DirectDebitDetail
    payment_stuff[:provider] = card.is_a?(Card) ? "credit_card" : "sepa"
    payment_stuff[:fee] = card.is_a?(Card) ? 33 : 0

    result = {
      donation: {
        id: donation_id,
        nonprofit_id: nonprofit.id,
        supporter_id: supporter.id,

        card_id: payment_stuff[:card_id],

        date: Time.now,
        created_at: Time.now,
        updated_at: Time.now,
        event_id: data[:event] ? event.id : nil,
        campaign_id: data[:campaign] ? campaign.id : nil,
        anonymous: nil,
        amount: charge_amount,
        comment: nil,
        dedication: {"type" => "honor", "name" => "a name"},
        designation: "designation",
        imported_at: nil,
        manual: nil,
        offsite: nil,
        recurring: nil,
        recurring_donation_id: nil,
        origin_url: nil,
        payment_id: nil,
        profile_id: nil,

        charge_id: nil,
        payment_provider: payment_stuff[:provider],
        queued_for_import_at: nil,
        direct_debit_detail_id: payment_stuff[:direct_debit_detail_id]
      }

    }.with_indifferent_access

    unless payment_id.nil?
      result[:activity] = {}

      result[:payment] = {
        date: Time.now,
        donation_id: donation_id,
        fee_total: -payment_stuff[:fee],
        gross_amount: 100,
        id: payment_id || 55_555,
        kind: data[:recurring_donation] ? "RecurringDonation" : "Donation",
        net_amount: 100 - payment_stuff[:fee],
        nonprofit_id: nonprofit.id,
        refund_total: 0,
        supporter_id: supporter.id,
        towards: "designation",
        created_at: Time.now,
        updated_at: Time.now,
        search_vectors: nil
      }
      result[:charge] = {
        id: charge_id || 55_555,
        amount: charge_amount,

        card_id: payment_stuff[:card_id],
        created_at: Time.now,
        updated_at: Time.now,
        stripe_charge_id: stripe_charge_id,
        fee: payment_stuff[:fee],

        disbursed: nil,
        failure_message: nil,
        payment_id: payment_id || 55_555,
        nonprofit_id: nonprofit.id,
        status: "pending",
        profile_id: nil,
        supporter_id: supporter.id,
        ticket_id: nil,

        donation_id: donation_id,
        direct_debit_detail_id: payment_stuff[:direct_debit_detail_id]

      }
    end

    if data[:recurring_donation]
      result[:recurring_donation] = {
        id: data[:recurring_donation].id,
        active: true,
        paydate: data[:recurring_donation_expected][:paydate],
        interval: data[:recurring_donation_expected][:interval],
        time_unit: data[:recurring_donation_expected][:time_unit],
        start_date: data[:recurring_donation_expected][:start_date],
        end_date: nil,
        n_failures: 0,
        edit_token: default_edit_token,
        cancelled_by: nil,
        cancelled_at: nil,
        donation_id: donation_id,
        nonprofit_id: nonprofit.id,
        created_at: Time.now,
        updated_at: Time.now,
        failure_message: nil,
        origin_url: nil,
        amount: charge_amount,
        supporter_id: supporter.id,

        # removable fields
        card_id: nil,
        campaign_id: nil,
        anonymous: nil,
        email: supporter.email,
        profile_id: nil

      }

    end

    result
  end

  def generate_expected_refund(_data = {})
    {}.with_indifferent_access
  end

  def validation_unauthorized
    expect(QuerySourceToken).to receive(:get_and_increment_source_token).with(fake_uuid, nil).and_raise(AuthenticationError)
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a(AuthenticationError)
    }
  end

  def validation_expired
    expect(QuerySourceToken).to receive(:get_and_increment_source_token).with(fake_uuid, nil).and_raise(ExpiredTokenError)
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a(ExpiredTokenError)
    }
  end

  def validation_basic_validation
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a(ParamValidation::ValidationError)
      expect(e.message).to start_with "amount"
      expect_validation_errors(e.data, [
        {key: :amount, name: :required},
        {key: :amount, name: :is_integer},
        {key: :nonprofit_id, name: :required},
        {key: :nonprofit_id, name: :is_reference},
        {key: :supporter_id, name: :required},
        {key: :supporter_id, name: :is_reference},
        {key: :designation, name: :is_a},
        {key: :dedication, name: :is_a},
        {key: :campaign_id, name: :is_reference},
        {key: :event_id, name: :is_reference},
        {key: :token, name: :required},
        {key: :token, name: :format}
      ])
    }
  end

  def validation_invalid_token
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a(ParamValidation::ValidationError)
      expect(e.message).to eq "#{fake_uuid} doesn't represent a valid source"
    }
  end

  def find_error_supporter
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError

      expect_validation_errors(e.data, [{key: :supporter_id}])
    }
  end

  def find_error_nonprofit
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :nonprofit_id}])
    }
  end

  def find_error_campaign
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError

      expect_validation_errors(e.data, [{key: :campaign_id}])
    }
  end

  def find_error_event
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :event_id}])
    }
  end

  def find_error_ticket
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :ticket_id}])
    }
  end

  def find_error_profile
    expect { yield() }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect_validation_errors(e.data, [{key: :profile_id}])
    }
  end

  def validation_supporter_deleted
    supporter
    supporter.deleted = true
    supporter.save!
    expect { yield }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect(e.message).to include "deleted"
      expect_validation_errors(e.data, [{key: :supporter_id}])
    }
  end

  def validation_event_deleted
    event.deleted = true
    event.save!

    expect { yield }.to raise_error { |error|
      expect(error).to be_a ParamValidation::ValidationError
      expect_validation_errors(error.data, [{key: :event_id}])
      expect(error.message).to include "deleted"
      expect(error.message).to include "Event #{event.id}"
    }
  end

  def validation_campaign_deleted
    campaign.deleted = true
    campaign.save!

    expect { yield }.to raise_error { |error|
      expect(error).to be_a ParamValidation::ValidationError
      expect_validation_errors(error.data, [{key: :campaign_id}])
      expect(error.message).to include "deleted"
      expect(error.message).to include "Campaign #{campaign.id}"
    }
  end

  def validation_supporter_not_with_nonprofit
    expect { yield }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect(e.message).to include "Supporter"
      expect(e.message).to include "does not belong to nonprofit"
      expect_validation_errors(e.data, [{key: :supporter_id}])
    }
  end

  def validation_campaign_not_with_nonprofit
    expect { yield }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect(e.message).to include "Campaign"
      expect(e.message).to include "does not belong to nonprofit"
      expect_validation_errors(e.data, [{key: :campaign_id}])
    }
  end

  def validation_event_not_with_nonprofit
    expect { yield }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect(e.message).to include "Event"
      expect(e.message).to include "does not belong to nonprofit"
      expect_validation_errors(e.data, [{key: :event_id}])
    }
  end

  def validation_card_not_with_supporter
    expect { yield }.to raise_error { |e|
      expect(e).to be_a ParamValidation::ValidationError
      expect(e.message).to include "Supporter"
      expect(e.message).to include "does not own card"
      expect_validation_errors(e.data, [{key: :token}])
    }
  end

  def handle_charge_failed
    failure_message = "failure message"

    expect(InsertCharge).to receive(:with_stripe).and_return("charge" => {"status" => "failed", "failure_message" => failure_message})

    expect { yield }.to raise_error { |e|
      expect(e).to be_a ChargeError
      expect(e.message).to eq failure_message

      expect(Donation.count).to eq 0
      expect(Charge.count).to eq 0
      expect(Activity.count).to eq 0
      expect(Payment.count).to eq 0
    }
  end

  def before_each_success(expect_charge = true)
    expect(InsertDonation).to receive(:insert_donation).and_wrap_original do |m, *args|
      result = m.call(*args)
      @donation_id = result.id
      result
    end

    if expect_charge
      nonprofit.stripe_account_id = Stripe::Account.create["id"]
      nonprofit.save!
      card.stripe_customer_id = "some other id"
      cust = Stripe::Customer.create
      card.stripe_customer_id = cust["id"]
      card.save!

      expect(Stripe::Charge).to receive(:create).and_wrap_original { |m, *args|
        a = m.call(*args)
        @stripe_charge_id = a["id"]
        a
      }
    end
  end

  def before_each_successful_refund
    expect(InsertRefund).to receive(:with_stripe).and_wrap_original do |m, *args|
      result = m.call(*args)
      @all_refunds&.push(result) || @all_refunds = [result]
      @fifo_refunds&.unshift(result) || @fifo_refunds = [result]

      result
    end

    expect(Stripe::Refund).to receive(:create).and_wrap_original do |m, *args|
      a = m.call(*args)
      @stripe_refund_ids&.unshift(a["id"]) || @stripe_refund_ids = [a["id"]]
      a
    end
  end

  def before_each_sepa_success
    expect(InsertDonation).to receive(:insert_donation).and_wrap_original do |m, *args|
      result = m.call(*args)
      @donation_id = result.id
      result
    end
  end

  def process_event_donation(data = {})
    pay_method = data[:sepa] ? direct_debit_detail : card

    if data[:recurring_donation]
      expect(Houdini.event_publisher).to receive(:announce).with(:recurring_donation_create, instance_of(Donation), supporter.locale)
    else
      expect(Houdini.event_publisher).to receive(:announce).with(:donation_create, instance_of(Donation), supporter.locale)
    end
    result = yield
    expected = generate_expected(@donation_id, result["payment"].id, result["charge"].id, pay_method, supporter, nonprofit, @stripe_charge_id, event: event, recurring_donation_expected: data[:recurring_donation], recurring_donation: result["recurring_donation"])

    expect(result.count).to eq expected.count
    expect(result["donation"].attributes).to eq expected[:donation]
    expect(result["charge"].attributes).to eq expected[:charge]
    # expect(result[:json]['activity']).to eq expected[:activity]
    expect(result["payment"].attributes).to eq expected[:payment]
    if data[:recurring_donation]
      expect(result["recurring_donation"].attributes).to eq expected[:recurring_donation]
    end

    result
  end

  def process_campaign_donation(data = {})
    pay_method = data[:sepa] ? direct_debit_detail : card

    if data[:recurring_donation]
      expect(Houdini.event_publisher).to receive(:announce).with(:recurring_donation_create, instance_of(Donation), supporter.locale)
    else
      expect(Houdini.event_publisher).to receive(:announce).with(:donation_create, instance_of(Donation), supporter.locale)
    end
    result = yield
    expected = generate_expected(@donation_id, result["payment"].id, result["charge"].id, pay_method, supporter, nonprofit, @stripe_charge_id, campaign: campaign, recurring_donation_expected: data[:recurring_donation], recurring_donation: result["recurring_donation"])

    expect(result.count).to eq expected.count
    expect(result["donation"].attributes).to eq expected[:donation]
    expect(result["charge"].attributes).to eq expected[:charge]
    expect(result["payment"].attributes).to eq expected[:payment]
    if data[:recurring_donation]
      expect(result["recurring_donation"].attributes).to eq expected[:recurring_donation]
    end
    result
  end

  def process_general_donation(data = {})
    pay_method = data[:sepa] ? direct_debit_detail : card
    if data[:recurring_donation]
      expect(Houdini.event_publisher).to receive(:announce).with(:recurring_donation_create, instance_of(Donation), supporter.locale)
    else
      expect(Houdini.event_publisher).to receive(:announce).with(:donation_create, instance_of(Donation), supporter.locale)
    end
    result = yield
    expect_payment = nil_or_true(data[:expect_payment])
    expect_charge = nil_or_true(data[:expect_charge])

    expected = generate_expected(@donation_id, nil_or_true(data[:expect_payment]) ? result["payment"].id : nil, nil_or_true(data[:expect_payment]) ? result["charge"].id : nil, pay_method, supporter, nonprofit, @stripe_charge_id, recurring_donation_expected: data[:recurring_donation], recurring_donation: result["recurring_donation"])

    expected["donation"][:profile_id] = profile.id
    expect(result.count).to eq expected.count
    expect(result["donation"].attributes).to eq expected[:donation]
    expect(result["charge"].attributes).to eq expected[:charge] if expect_charge
    # expect(result[:json]['activity']).to eq expected[:activity]

    if expect_payment
      expect(result["payment"].attributes).to eq expected[:payment]
    end

    if data[:recurring_donation]
      expect(result["recurring_donation"].attributes).to eq expected[:recurring_donation]
    end

    result
  end

  def process_general_refund(_data = {})
    result = yield

    expected = generate_expected_refund

    expect(result["payment"]).to eq expected[:payment]
    expect(result["refund"]).to eq expected[:refund]
    result
  end

  def nil_or_true(item)
    item.nil? || item
  end
end
