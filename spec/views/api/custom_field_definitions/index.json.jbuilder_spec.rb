# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/custom_field_definitions/index.json.jbuilder" do
  subject(:json) do
    assign(:custom_field_definitions, Kaminari.paginate_array([custom_field_definition]).page)
    render
    JSON.parse(rendered)
  end

  let(:custom_field_definition) { create(:custom_field_definition_with_nonprofit) }
  let(:nonprofit) { custom_field_definition.nonprofit }

  it { expect(json["data"].count).to eq 1 }

  describe "details of the first item" do
    subject(:first) do
      json["data"].first
    end

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

  describe "paging" do
    subject(:json) do
      custom_field_definition
      6.times do |i|
        create(:custom_field_definition_with_nonprofit,
          nonprofit: nonprofit,
          name: i)
      end
      assign(:custom_field_definitions, nonprofit.custom_field_definitions.order("id DESC").page.per(5))
      render
      JSON.parse(rendered)
    end

    it { is_expected.to include("data" => have_attributes(count: 5)) }
    it { is_expected.to include("first_page" => true) }
    it { is_expected.to include("last_page" => false) }
    it { is_expected.to include("current_page" => 1) }
    it { is_expected.to include("requested_size" => 5) }
    it { is_expected.to include("total_count" => 7) }
  end
end
