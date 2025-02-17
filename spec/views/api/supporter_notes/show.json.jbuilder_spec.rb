# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/supporter_notes/show.json.jbuilder" do
  subject(:json) do
    view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
    assign(:supporter_note, supporter_note)
    render
    JSON.parse(rendered)
  end

  let(:supporter) { supporter_note.supporter }
  let(:nonprofit) { supporter.nonprofit }
  let(:user) { supporter_note.user }

  let(:supporter_note) { create(:supporter_note_with_fv_poverty_with_user) }

  it {
    is_expected.to include("object" => "supporter_note")
  }

  it {
    is_expected.to include("id" => supporter_note.id)
  }

  it {
    is_expected.to include("content" => "Some content in our note")
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("deleted" => false)
  }

  it {
    is_expected.to include("supporter" => supporter.id)
  }

  it {
    is_expected.to include("user" => user.id)
  }

  it {
    is_expected.to include("url" =>
      a_string_matching(
        %r{http://test\.host/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_notes/#{supporter_note.id}}
      ))
  }
end
