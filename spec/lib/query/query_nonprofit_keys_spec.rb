# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe QueryNonprofitKeys do
  around(:each) { |example|
    current_cypher_key = ENV["CYPHER_KEY"]
    ENV["CYPHER_KEY"] = "xGhMrqIixKvQ4S1bqv8CYwxGhMrqIixKvQ4S1bqv8CY=\n" # test cypher key; don't use anywhere for real code
    example.run
    ENV["CYPHER_KEY"] = current_cypher_key
  }

  let!(:nonprofit_key) { create(:nonprofit_key) }

  it "returns the mailchimp token" do
    expect(QueryNonprofitKeys.get_key(nonprofit_key.nonprofit_id, "mailchimp_token")).to eq "a token"
  end

  it "refuses any other method name" do
    expect { QueryNonprofitKeys.get_key(nonprofit_key.nonprofit_id, "destroy") }.to raise_error(ActiveRecord::RecordNotFound)
    expect(NonprofitKey.exists?(nonprofit_key.id)).to be true
  end
end
