# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :ticket_level do
    trait :has_tickets do
    end
  end

  factory :ticket_level_with_event, class: "TicketLevel" do
    event { create(:fv_poverty_fighting_event_with_nonprofit_and_profile) }
    factory :ticket_level_with_event_non_admin__order_3__not_deleted do
      name { "ticket level name" }
      description { "desc ticket" }
      amount { 200 }
      admin_only { false }
      deleted { false }
      limit { 2 }
      order { 3 }
    end
  end
end
