# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later 
require "rails_helper"

RSpec.describe "event_discounts/create.json.jbuilder", type: :view do
  let(:event_discount) { create(:event_discount_base) }
  subject(:json) do
    assign(:event_discount, event_discount)
    render
    JSON.parse(rendered)
  end

  it do
    is_expected.to eq(event_discount.attributes.slice("code", "event_id", "id", "name", "percent"))
  end
end
