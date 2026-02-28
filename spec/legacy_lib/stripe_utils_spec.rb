# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe StripeUtils, pending: true do
  # describe '.get_verification_status' do
  #   it 'returns "verified" if the account has transfers enabled' do
  #     acct = double("Stripe::Account", {transfers_enabled: true})
  #     status = VCR.use_cassette('StripeUtils/verification_status_verified'){StripeUtils.get_verification_status(acct)}
  #     expect(status).to eq("verified")
  #   end
  #
  #   it 'returns the status if transfers arent enabled' do
  #     acct = double("Stripe::Account", {transfers_enabled: nil})
  #     allow(acct).to receive_message_chain(:legal_entity, :verification, :status).and_return("the_status")
  #     expect(StripeUtils.get_verification_status(acct)).to eq("the_status")
  #   end
  # end
end
