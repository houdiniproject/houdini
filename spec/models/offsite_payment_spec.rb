# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe OffsitePayment, type: :model do
  it { is_expected.to have_db_column(:gross_amount).of_type(:integer) }
  it { is_expected.to have_db_column(:kind).of_type(:string) }
  it { is_expected.to have_db_column(:date).of_type(:datetime) }
  it { is_expected.to have_db_column(:check_number).of_type(:string) }

  it { is_expected.to belong_to(:payment) }
  it { is_expected.to belong_to(:donation) }
  it { is_expected.to belong_to(:nonprofit) }
  it { is_expected.to belong_to(:supporter) }
end
