# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'stripe_mock'

RSpec.shared_context :shared_donation_charge_context do
  let(:nonprofit) { force_create(:nonprofit, name: "nonprofit name", slug: 'nonprofit_nameo')}
  let(:other_nonprofit) { force_create(:nonprofit)}
  let(:supporter) {force_create(:supporter, :nonprofit => nonprofit, locale: 'locale_one')}
  let(:other_nonprofit_supporter) { force_create(:supporter, nonprofit: other_nonprofit, locale: 'locale_two')}
  let(:card) {force_create(:card, :holder => supporter)}
  let(:card_for_other_supporter) { force_create(:card, holder: other_nonprofit_supporter)}
  let(:card_with_valid_stripe_id) { force_create(:card, :holder => supporter)}
  let(:direct_debit_detail) { force_create(:direct_debit_detail, holder:supporter)}
  let(:direct_debit_detail_for_other_supporter) { force_create(:direct_debit_detail, holder: other_nonprofit_supporter)}
  let(:bp_percentage) { 0.039 }
  let(:billing_plan) {force_create(:billing_plan, :percentage_fee => bp_percentage)}
  let(:billing_subscription) { force_create(:billing_subscription, :billing_plan => billing_plan, :nonprofit => nonprofit)}
  let(:campaign) {force_create(:campaign, nonprofit: nonprofit, goal_amount: 500)}
  let(:other_campaign) {force_create(:campaign, nonprofit: other_nonprofit)}
  let(:event) {
    Event.any_instance.stub(:geocode).and_return([1,1])
    force_create(:event, nonprofit: nonprofit)
  }
  let(:other_event) {
    Event.any_instance.stub(:geocode).and_return([1,1])
    force_create(:event, nonprofit: other_nonprofit)
  }
  let(:event_discount) {force_create(:event_discount, event: event, percent: 20)}
  let(:other_event_discount) {force_create(:event_discount, event: other_event)}
  let(:profile) {force_create(:profile)}
  let(:user) { force_create(:user)}
  let(:ticket_level) {force_create(:ticket_level, event: event, amount: 400, name: "1")}
  let(:ticket_level2) {force_create(:ticket_level, event: event, amount: 500, name: "2")}
  let(:free_ticket_level) {force_create(:ticket_level, event: event, amount: 0, name: 'free ticket level')}
  let(:other_ticket_level) {force_create(:ticket_level, event: other_event, name: "3")}

  let(:donation_for_rd) {force_create(:donation, recurring: true, nonprofit: nonprofit, supporter: supporter, card: card_with_valid_stripe_id, amount: 500)}
  let(:recurring_donation) {force_create(:recurring_donation, donation: donation_for_rd, nonprofit: nonprofit, supporter:supporter, start_date: Time.now, interval: 1, time_unit: 'month')}

  let(:supporter_address) {force_create(:address, supporter:supporter, name: "address - first", address: "515325 something st.", city:"Appleton", state_code: "WI", country: nil)}
  let(:supporter_address_2) {force_create(:address, supporter:supporter, name: "address - another", address: "515325 something st.", city:"Appleton", state_code: "il", country: "USA", zip_code: "5215890-RD")}
  let(:other_supporter_address) {force_create(:address, supporter:other_supporter, address: nil, city: "Chicago", state_code: "AZ", country: "Ireland")}

  let(:stripe_helper) { StripeMock.create_test_helper }

  around(:each){|example|
    Timecop.freeze(2020, 5, 4) do
      StripeMock.start
      example.run
      StripeMock.stop
    end
  }
end