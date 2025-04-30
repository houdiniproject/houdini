# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe NonprofitKey, type: :model do
  around(:each) { |example|
    current_cypher_key = ENV["CYPHER_KEY"]
    ENV["CYPHER_KEY"] = "xGhMrqIixKvQ4S1bqv8CYwxGhMrqIixKvQ4S1bqv8CY=\n" # test cypher key; don't use anywhere for real code
    example.run
    ENV["CYPHER_KEY"] = current_cypher_key
  }

  it {
    is_expected.to belong_to(:nonprofit).required(true)
  }

  it {
    is_expected.to validate_presence_of(:mailchimp_token)
  }

  describe "#mailchimp_token" do
    it {
      expect(create(:nonprofit_key).mailchimp_token).to eq "a token"
    }

    it "roundtrips mailchimp_token properly" do
      key = create(:nonprofit_key)
      key.mailchimp_token = "a different token"
      key.save!

      new_key_object = NonprofitKey.find(key.id)

      expect(new_key_object.mailchimp_token).to eq "a different token"
    end

    it "handles nil values properly" do
      key = create(:nonprofit_key)
      expect {
        key.mailchimp_token = nil
      }.to_not raise_error
      expect(key.mailchimp_token).to be_nil
    end
  end
end
