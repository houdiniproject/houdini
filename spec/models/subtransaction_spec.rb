# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Subtransaction, type: :model do
  it_behaves_like "a class with payments extension", :subtransaction_payments, :subtransaction_for_testing_payment_extensions

  it {
    is_expected.to(belong_to(:trx)
      .class_name("Transaction")
      .with_foreign_key("transaction_id")
      .inverse_of(:subtransaction))
  }

  it {
    is_expected.to(have_one(:supporter).through(:trx))
  }

  it {
    is_expected.to(have_one(:nonprofit).through(:trx))
  }

  it {
    is_expected.to(have_many(:subtransaction_payments))
  }

  it {
    is_expected.to delegate_method(:currency).to(:nonprofit)
  }

  it {
    is_expected.to delegate_method(:to_houid).to(:subtransactable)
  }

  it {
    is_expected.to validate_presence_of :subtransactable
  }
end
