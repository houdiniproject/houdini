# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe NonprofitS3Key, type: :model do
  it { is_expected.to belong_to(:nonprofit).required }

  it { is_expected.to validate_presence_of(:access_key_id) }
  it { is_expected.to validate_presence_of(:secret_access_key) }
  it { is_expected.to validate_presence_of(:bucket_name) }
end
