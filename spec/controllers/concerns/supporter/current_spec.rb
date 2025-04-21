# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe "Controllers::Supporter::Current" do
  let(:nonprofit) { force_create(:nm_justice) }
  let(:supporter) { force_create(:supporter) }

  controller(ApplicationController) do
    include Controllers::User::Authorization
    include Controllers::Supporter::Current

    def index
      render json: {
        supporter: "supporters: #{current_supporter.id}",
        nonprofit: "nonprofit: #{current_nonprofit.id}"
      }
    end
  end

  it "handles situations where we use id" do
    nonprofit
    supporter
    get :index, params: {nonprofit_id: nonprofit.id, id: supporter.id}
    expect(response.parsed_body).to eq(
      {
        "supporter" => "supporters: #{supporter.id}",
        "nonprofit" => "nonprofit: #{nonprofit.id}"
      }
    )
  end

  it "handles situations where we use supporter_id" do
    nonprofit
    supporter

    get :index, params: {nonprofit_id: nonprofit.id, supporter_id: supporter.id, id: 1}
    expect(response.parsed_body).to eq(
      {
        "supporter" => "supporters: #{supporter.id}",
        "nonprofit" => "nonprofit: #{nonprofit.id}"
      }
    )
  end
end
