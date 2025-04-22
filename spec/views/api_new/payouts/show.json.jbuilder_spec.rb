# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api_new/payouts/show.json.jbuilder", type: :view do
  let(:payout) { build(:payout, nonprofit: build(:nonprofit)) }
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(1)
    assign(:payout, payout)
    render
    rendered
  end

  it do
    is_expected.to include_json(id: payout.houid,
      created: payout.created_at.to_i,
      net_amount: {
        cents: payout.net_amount_as_money.cents,
        currency: "usd"
      },
      status: payout.status,
      object: "payout")
  end
end
