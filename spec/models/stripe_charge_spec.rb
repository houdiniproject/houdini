# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe StripeCharge, type: :model do
  describe "charge.succeeded" do
    include_context :charge_succeeded_specs

    let(:obj) { StripeCharge.create(object: json) }
  end
end
