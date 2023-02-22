# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Payout, :type => :model do

  it {is_expected.to have_db_column(:net_amount)}
  it {is_expected.to have_db_column(:failure_message)}
  it {is_expected.to have_db_column(:status)}
  it {is_expected.to have_db_column(:fee_total)}
  it {is_expected.to have_db_column(:gross_amount)}
  it {is_expected.to have_db_column(:bank_name)}
  it {is_expected.to have_db_column(:email)}
  it {is_expected.to have_db_column(:count)}
  it {is_expected.to have_db_column(:manual)}
  it {is_expected.to have_db_column(:scheduled)}
  it {is_expected.to have_db_column(:stripe_transfer_id)}
  it {is_expected.to have_db_column(:user_ip)}

  it {is_expected.to belong_to(:nonprofit)}
  it {is_expected.to have_one(:bank_account).through(:nonprofit)}
  it {is_expected.to have_many(:payment_payouts)}
  it {is_expected.to have_many(:payments).through(:payment_payouts)}
  it {is_expected.to have_many(:object_events)}

  it {is_expected.to validate_presence_of(:stripe_transfer_id)}
  it {is_expected.to validate_uniqueness_of(:stripe_transfer_id)}
  it {is_expected.to validate_presence_of(:nonprofit)}
  it {is_expected.to validate_presence_of(:bank_account)}
  it {is_expected.to validate_presence_of(:email)}
  it {is_expected.to validate_presence_of(:net_amount)}

  it {is_expected.to delegate_method(:currency).to(:nonprofit)}
  
  it_behaves_like 'an houidable entity', :pyout, :houid

  it_behaves_like 'an object with as_money attributes', :net_amount
end
