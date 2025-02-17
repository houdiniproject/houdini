# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/supporters/index.json.jbuilder" do
  subject(:json) do
    assign(:supporters, supporter_with_fv_poverty.nonprofit.supporters.order("id DESC").page)
    render
    JSON.parse(rendered)
  end

  let(:supporter_with_fv_poverty) { create(:supporter_with_fv_poverty) }

  it { expect(json["data"].count).to eq 1 }

  describe "details of the first item" do
    subject(:first) do
      json["data"].first
    end

    let(:supporter) { supporter_with_fv_poverty }
    let(:nonprofit) { supporter.nonprofit }

    let(:id) { first["id"] }

    it {
      is_expected.to include("object" => "supporter")
    }

    it {
      is_expected.to include("id" => supporter.id)
    }

    it {
      is_expected.to include("name" => "Fake Supporter Name")
    }

    it {
      is_expected.to include("nonprofit" => nonprofit.id)
    }

    it {
      is_expected.to include("anonymous" => false)
    }

    it {
      is_expected.to include("deleted" => false)
    }

    it {
      is_expected.to include("merged_into" => nil)
    }

    it {
      is_expected.to include("organization" => nil)
    }

    it {
      is_expected.to include("phone" => nil)
    }

    it {
      is_expected.to include("supporter_addresses" => [id])
    }

    it {
      is_expected.to include("url" =>
        a_string_matching(%r{http://test\.host/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}}))
    }
  end

  describe "paging" do
    subject(:json) do
      supporter_with_fv_poverty
      6.times do |i|
        create(:supporter_with_fv_poverty, nonprofit: supporter_with_fv_poverty.nonprofit, name: i,
          email: "email#{i}@email#{i}.com")
      end
      assign(:supporters, supporter_with_fv_poverty.nonprofit.supporters.order("id DESC").page.per(5))
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
