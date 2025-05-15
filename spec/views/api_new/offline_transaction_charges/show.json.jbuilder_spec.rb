# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api_new/offline_transaction_charges/show.json.jbuilder", type: :view do
  let(:transaction) { create(:transaction_for_offline_donation) }
  let(:offline_transaction_charge) { transaction.subtransaction.subtransaction_payments.first.offline_transaction_charge }

  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(1)
    assign(:offline_transaction_charge, offline_transaction_charge)
    render
    rendered
  end

  it {
    is_expected.to include_json(object: "offline_transaction_charge",
      created: offline_transaction_charge.created.to_i,
      kind: offline_transaction_charge.subtransaction_payment.legacy_payment.offsite_payment&.kind,
      check_number: offline_transaction_charge.subtransaction_payment.legacy_payment.offsite_payment&.check_number,
      net_amount: {
        cents: offline_transaction_charge.net_amount_as_money.cents,
        currency: "usd"
      },
      gross_amount: {
        cents: offline_transaction_charge.gross_amount_as_money.cents,
        currency: "usd"
      },
      fee_total: {
        cents: offline_transaction_charge.fee_total_as_money.cents,
        currency: "usd"
      })
  }
end
