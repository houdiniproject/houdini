# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/mailchimp/list.json.jbuilder", type: :view do
  describe "supporter with no active recurring donations" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(1)
      assign(:supporter, create(:supporter, name: "Penelope Schultz"))
      render
      rendered
    end

    it {
      is_expected.to include_json(
        email_address: Supporter.first.email,
        status: "subscribed",
        merge_fields: {
          F_NAME: "Penelope",
          L_NAME: "Schultz"
        }
      )
    }
  end

  # TODO: Fix this spec
  describe "supporter with active recurring donations", skip: "TODO" do
  end
end
