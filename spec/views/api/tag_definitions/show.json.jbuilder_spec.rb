# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/tag_definitions/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:tag_definition, tag_definition)
    render
    JSON.parse(rendered)
  end

  let(:tag_definition) { create(:tag_definition_with_nonprofit) }
  let(:nonprofit) { tag_definition.nonprofit }

  it {
    is_expected.to include("object" => "tag_definition")
  }

  it {
    is_expected.to include("id" => tag_definition.id)
  }

  it {
    is_expected.to include("name" => "Tag Name")
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("deleted" => false)
  }

  it {
    is_expected.to include("url" =>
      a_string_matching(
        %r{http://test\.host/api/nonprofits/#{nonprofit.id}/tag_definitions/#{tag_definition.id}}
      ))
  }
end
