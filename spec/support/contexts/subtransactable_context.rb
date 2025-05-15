# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

shared_examples "subtransactable" do |prefix, factory_for_payment_extension_testing|
  it_behaves_like "an houidable entity", prefix, :houid

  it_behaves_like "a class with payments extension", :subtransaction_payments, factory_for_payment_extension_testing

  it_behaves_like "an object with as_money attributes", :amount, :net_amount

  it {
    is_expected.to have_one(:subtransaction).dependent(:nullify)
  }

  it {
    is_expected.to(have_one(:trx)
      .class_name("Transaction")
      .through(:subtransaction)
      .with_foreign_key("transaction_id"))
  }

  it {
    is_expected.to have_one(:supporter).through(:trx)
  }

  it {
    is_expected.to have_one(:nonprofit).through(:trx)
  }

  it {
    is_expected.to have_many(:subtransaction_payments).through(:subtransaction)
  }

  it {
    is_expected.to delegate_method(:currency).to(:nonprofit)
  }
end
