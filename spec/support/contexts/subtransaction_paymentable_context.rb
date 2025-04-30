# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_examples "subtransaction paymentable" do |prefix|
  it_behaves_like "an houidable entity", prefix, :houid
  it_behaves_like "an object with as_money attributes", :gross_amount, :net_amount, :fee_total

  it {
    is_expected.to have_one(:subtransaction_payment).dependent(:destroy)
  }

  it {
    is_expected.to(have_one(:trx)
      .class_name("Transaction")
      .through(:subtransaction_payment)
      .with_foreign_key("transaction_id"))
  }

  it {
    is_expected.to(have_one(:legacy_payment)
      .class_name("Payment")
      .through(:subtransaction_payment))
  }

  it {
    is_expected.to delegate_method(:gross_amount).to(:legacy_payment)
  }

  it {
    is_expected.to delegate_method(:net_amount).to(:legacy_payment)
  }

  it {
    is_expected.to delegate_method(:fee_total).to(:legacy_payment)
  }

  it {
    is_expected.to have_one(:supporter).through(:subtransaction_payment)
  }

  it {
    is_expected.to have_one(:nonprofit).through(:subtransaction_payment)
  }

  it {
    is_expected.to have_one(:subtransaction).through(:subtransaction_payment)
  }

  it {
    is_expected.to have_many(:object_events)
  }

  it {
    is_expected.to delegate_method(:currency).to(:nonprofit)
  }
end
