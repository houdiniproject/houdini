# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_context 'with json results for subtransaction on transaction_for_donation' do
	around do |ex|
		Timecop.freeze(2020, 5, 4) do
			ex.run
		end
	end

	it {
		is_expected.to include('object' => 'subtransaction')
	}

	it {
		is_expected.to include('id' => match_houid('offlinetrx'))
	}

	it {
		is_expected.to include('created' => Time.current.to_i)
	}
	
	it {
		is_expected.to include('type' => 'subtransaction')
	}

	it {
		is_expected.to include('object' => 'offline_transaction')
	}

	it {
		is_expected.to include(
			'amount' => {
				'cents' => 4000,
				'currency' => 'usd'
			}
		)
	}

	it {
		is_expected.to include(
			'transaction' => match_houid('trx')
		)
	}

	it {
		is_expected.to include(
			'subtransaction_payments' => [{
				'id' => match_houid('offtrxchrg'),
				'type' => 'payment',
				'object' => 'offline_transaction_charge'
			}]
		)
	}

	it {
		is_expected.to include('nonprofit' => nonprofit.id)
	}

	it {
		is_expected.to include('supporter' => supporter.id)
	}

	it {
		is_expected.to include('url' =>
			subtransaction_url(nonprofit.id, transaction.id))
	}
end
