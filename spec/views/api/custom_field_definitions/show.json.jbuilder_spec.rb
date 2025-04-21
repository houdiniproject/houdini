# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/custom_field_definitions/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:custom_field_definition, custom_field_definition)
    render
    JSON.parse(rendered)
  end

  let(:custom_field_definition) { create(:custom_field_definition_with_nonprofit) }
  let(:nonprofit) { custom_field_definition.nonprofit }

  it {
    is_expected.to include("object" => "custom_field_definition")
  }

  it {
    is_expected.to include("id" => custom_field_definition.id)
  }

  it {
    is_expected.to include("name" => "Def Name")
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
        %r{http://test\.host/api/nonprofits/#{nonprofit.id}/custom_field_definitions/#{custom_field_definition.id}}
      ))
  }
end
