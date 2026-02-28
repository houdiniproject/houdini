# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_context "with json results for transaction_for_donation" do
  around do |ex|
    Timecop.freeze(2020, 5, 4) do
      ex.run
    end
  end

  it {
    is_expected.to include("object" => "transaction")
  }

  it {
    is_expected.to include("id" => transaction.id)
  }

  it {
    is_expected.to include("created" => Time.current.to_i)
  }

  it {
    is_expected.to include(
      "amount" => {
        "cents" => 4000,
        "currency" => "usd"
      }
    )
  }

  it {
    is_expected.to include(
      "subtransaction" => {
        "id" => match_houid("offlinetrx"),
        "type" => "subtransaction",
        "object" => "offline_transaction"
      }
    )
  }

  it {
    is_expected.to include(
      "payments" => [{
        "id" => match_houid("offtrxchrg"),
        "type" => "payment",
        "object" => "offline_transaction_charge"
      }]
    )
  }

  it {
    is_expected.to include(
      "transaction_assignments" => [{
        "id" => match_houid("don"),
        "type" => "trx_assignment",
        "object" => "donation"
      }]
    )
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("supporter" => supporter.id)
  }

  it {
    is_expected.to include("url" =>
      base_url(nonprofit.id, transaction.id))
  }
end
