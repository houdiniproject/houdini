# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe EmailCustomization, type: :model do
  it { is_expected.to have_db_column(:contents) }
  it { is_expected.to validate_presence_of(:contents) }

  it { is_expected.to have_db_column(:name) }
  it { is_expected.to have_db_index(:name) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to belong_to(:nonprofit).required(true) }
  it { is_expected.to have_db_index(:nonprofit_id) }
end
