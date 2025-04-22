# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "stripe_mock"

RSpec.shared_context :shared_donation_charge_context do
  let(:nonprofit) { force_create(:nm_justice, name: "nonprofit name", slug: "nonprofit_nameo") }
  let(:other_nonprofit) { force_create(:fv_poverty) }
  let(:supporter) { force_create(:supporter, nonprofit: nonprofit, locale: "locale_one") }
  let(:other_nonprofit_supporter) { force_create(:supporter, nonprofit: other_nonprofit, locale: "locale_two") }
  let(:card) { force_create(:card, holder: supporter) }
  let(:card_for_other_supporter) { force_create(:card, holder: other_nonprofit_supporter) }
  let(:card_with_valid_stripe_id) { force_create(:card, holder: supporter) }
  let(:direct_debit_detail) { force_create(:direct_debit_detail, holder: supporter) }
  let(:direct_debit_detail_for_other_supporter) { force_create(:direct_debit_detail, holder: other_nonprofit_supporter) }
  let(:bp_percentage) { 0.039 }
  let(:billing_plan) { force_create(:billing_plan, percentage_fee: bp_percentage) }
  let(:billing_subscription) { force_create(:billing_subscription, billing_plan: billing_plan, nonprofit: nonprofit) }
  let(:campaign) { force_create(:campaign, nonprofit: nonprofit, goal_amount: 500) }
  let(:other_campaign) { force_create(:campaign, nonprofit: other_nonprofit) }
  let(:event) do
    force_create(:event, nonprofit: nonprofit)
  end
  let(:other_event) do
    force_create(:event, nonprofit: other_nonprofit)
  end
  let(:event_discount) { force_create(:event_discount, event: event, percent: 20) }
  let(:other_event_discount) { force_create(:event_discount, event: other_event) }
  let(:profile) { force_create(:profile) }
  let(:user) { force_create(:user) }
  let(:ticket_level) { force_create(:ticket_level, event: event, amount: 400, name: "1") }
  let(:ticket_level2) { force_create(:ticket_level, event: event, amount: 500, name: "2") }
  let(:free_ticket_level) { force_create(:ticket_level, event: event, amount: 0, name: "free ticket level") }
  let(:other_ticket_level) { force_create(:ticket_level, event: other_event, name: "3") }

  let(:donation_for_rd) { force_create(:donation, recurring: true, nonprofit: nonprofit, supporter: supporter, card: card_with_valid_stripe_id, amount: 500) }
  let(:recurring_donation) { force_create(:recurring_donation, donation: donation_for_rd, nonprofit: nonprofit, supporter: supporter, start_date: Time.now, interval: 1, time_unit: "month") }
  let(:recurrence) { force_create(:recurrence, recurring_donation: recurring_donation, supporter: supporter, amount: 500, start_date: Time.now) }

  let(:stripe_helper) { StripeMockHelper.default_helper }

  let(:supporter_name) { "Fake Supporter Name" }

  let(:nonprofit_to_builder_base) do
    {
      "id" => nonprofit.id,
      "name" => nonprofit.name,
      "object" => "nonprofit"
    }
  end

  let(:supporter_to_builder_base) do
    {
      "anonymous" => false,
      "deleted" => false,
      "name" => supporter_name,
      "organization" => nil,
      "phone" => nil,
      "supporter_addresses" => [kind_of(Numeric)],
      "id" => kind_of(Numeric),
      "merged_into" => nil,
      "nonprofit" => nonprofit.id,
      "object" => "supporter"
    }
  end

  let(:supporter_address_to_builder_base) do
    {
      "id" => kind_of(Numeric),
      "deleted" => false,
      "address" => address,
      "city" => nil,
      "state_code" => nil,
      "zip_code" => nil,
      "country" => "United States",
      "object" => "supporter_address",
      "supporter" => kind_of(Numeric),
      "nonprofit" => nonprofit.id
    }
  end

  around do |example|
    Timecop.freeze(2020, 5, 4) do
      StripeMockHelper.mock do
        example.run
      end
    end
  end
end
