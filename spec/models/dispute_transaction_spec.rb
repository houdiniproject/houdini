# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe DisputeTransaction, :type => :model do
  it {is_expected.to belong_to(:dispute)}
  it {is_expected.to belong_to(:payment)}

  it { is_expected.to have_one(:nonprofit).through(:dispute) }
  it { is_expected.to have_one(:supporter).through(:dispute) }
end
