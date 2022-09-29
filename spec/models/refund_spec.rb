# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Refund, type: :model do
  it { is_expected.to belong_to(:charge) }
  it { is_expected.to belong_to(:payment) }
  it { is_expected.to have_one(:subtransaction_payment).through(:payment)}
  it { is_expected.to have_one(:misc_refund_info) }

  it { is_expected.to have_one(:nonprofit).through(:charge) }
  it { is_expected.to have_one(:supporter).through(:charge) }
  it {is_expected.to have_many( :manual_balance_adjustments)}
end
