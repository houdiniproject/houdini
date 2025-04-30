# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe SubtransactionPayment, type: :model do
  it {
    is_expected.to(belong_to(:subtransaction).inverse_of(:subtransaction_payments))
  }

  it {
    is_expected.to(have_one(:trx)
      .class_name("Transaction")
      .with_foreign_key("transaction_id")
      .through(:subtransaction))
  }

  it {
    is_expected.to(have_one(:supporter).through(:subtransaction))
  }

  it {
    is_expected.to(have_one(:nonprofit).through(:subtransaction))
  }

  it {
    is_expected.to(belong_to(:legacy_payment).class_name("Payment").required(true))
  }

  it {
    is_expected.to delegate_method(:gross_amount).to(:paymentable)
  }

  it {
    is_expected.to delegate_method(:fee_total).to(:paymentable)
  }

  it {
    is_expected.to delegate_method(:publish_created).to(:paymentable)
  }

  it {
    is_expected.to delegate_method(:publish_updated).to(:paymentable)
  }

  it {
    is_expected.to delegate_method(:publish_deleted).to(:paymentable)
  }

  it {
    is_expected.to delegate_method(:to_houid).to(:paymentable)
  }

  it {
    is_expected.to validate_presence_of(:paymentable)
  }
end
