# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe NonprofitDeactivation, type: :model do
  def create_activated_and_unactivated_nps
    OpenStruct.new(activated: [create(:nonprofit_base),
      create(:nonprofit_base, :activated_deactivation_record)],
      deactivated: [create(:nonprofit_base, :deactivate_nonprofit)])
  end

  describe ".activated" do
    it "has all of the nps in activated except last one" do
      nps = create_activated_and_unactivated_nps

      expect(Nonprofit.activated.all).to match_array(nps.activated)
    end
  end

  it "has only nps in deactivated" do
    nps = create_activated_and_unactivated_nps
    expect(Nonprofit.deactivated.all).to match_array(nps.deactivated)
  end
end
