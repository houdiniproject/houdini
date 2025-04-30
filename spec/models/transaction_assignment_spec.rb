# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe TransactionAssignment, type: :model do
  it {
    is_expected.to(belong_to(:trx)
      .class_name("Transaction")
      .with_foreign_key("transaction_id").required(true)
      .inverse_of(:transaction_assignments))
  }

  it {
    is_expected.to(have_one(:supporter).through(:trx))
  }

  it {
    is_expected.to(have_one(:nonprofit).through(:trx))
  }

  it {
    is_expected.to delegate_method(:to_houid).to(:assignable)
  }

  it {
    is_expected.to validate_presence_of(:assignable)
  }
end
