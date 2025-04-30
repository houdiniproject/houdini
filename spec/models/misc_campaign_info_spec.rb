# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe MiscCampaignInfo, type: :model do
  it { is_expected.to have_db_column(:fee_coverage_option_config).of_type(:string).with_options(null: true, default: nil) }

  it { is_expected.to validate_inclusion_of(:fee_coverage_option_config).in_array(["auto", "manual", "none", nil]) }
end
