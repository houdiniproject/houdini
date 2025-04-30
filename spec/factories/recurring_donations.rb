# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :recurring_donation do
  end

  factory :recurring_donation_base, class: "RecurringDonation" do
    active { true }
    sequence(:edit_token) { |i| "edit_token_#{i}" }
    start_date { Time.current }
    interval { 1 }
    time_unit { "month" }
  end
end
