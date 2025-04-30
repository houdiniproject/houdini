# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Event, type: :model do
  it { is_expected.to have_many(:ticketholders).through(:tickets).source(:supporter) }
end
