# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe Controllers::ApiNew::Transaction::Current, type: :controller do
  let(:transaction) { create(:transaction_with_legacy_donation) }
  let(:nonprofit) { transaction.nonprofit }

  controller(ApiNew::ApiController) do
    include Controllers::ApiNew::Transaction::Current

    def index
      render json: {
        transaction: current_transaction.id
      }
    end
  end

  it "gets transaction if found" do
    get :index, params: {nonprofit_id: nonprofit.houid, id: transaction.houid}
    expect(JSON.parse(response.body)).to eq(
      {
        "transaction" => transaction.id
      }
    )
  end

  it "throw RecordNotFound if not found" do
    expect do
      get :index, params: {nonprofit_id: nonprofit.houid, id: 124_124_905}
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
