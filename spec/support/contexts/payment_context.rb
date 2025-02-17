# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_context "with json results for first payment on transaction_for_donation" do
  subject(:payment_json) do
    json
  end

  around do |ex|
    Timecop.freeze(2020, 5, 4) do
      ex.run
    end
  end

  it {
    is_expected.to include("id" => match_houid("offtrxchrg"))
  }

  it {
    is_expected.to include("type" => "payment")
  }

  it {
    is_expected.to include("object" => "offline_transaction_charge")
  }

  it {
    is_expected.to include("created" => Time.current.to_i)
  }

  it {
    is_expected.to include("gross_amount" => {
      "cents" => 4000,
      "currency" => "usd"
    })
  }

  it {
    is_expected.to include("fee_total" => {
      "cents" => 300,
      "currency" => "usd"
    })
  }

  it {
    is_expected.to include("net_amount" => {
      "cents" => 3700,
      "currency" => "usd"
    })
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("subtransaction" => {
      "id" => match_houid("offlinetrx"),
      "object" => "offline_transaction",
      "type" => "subtransaction"
    })
  }

  it {
    is_expected.to include("supporter" => supporter.id)
  }

  it {
    is_expected.to include(
      "url" =>
         payment_url(
           nonprofit.id,
           transaction.id,
           transaction.subtransaction.payments.first.paymentable.id
         )
    )
  }

  # describe('subtransaction') do
  # 	subject {
  # 		payment_json["subtransaction"]
  # 	}
  # 	it {
  # 		is_expected.to include('object' => 'offline_transaction')
  # 	}

  # 	it {
  # 		is_expected.to include('id' => match_houid('offlinetrx'))
  # 	}

  # 	it {
  # 		is_expected.to include('type' => 'subtransaction')
  # 	}
  # end
end
