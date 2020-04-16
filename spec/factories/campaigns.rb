# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :campaign do
    profile
    association :nonprofit, factory: :nm_justice
    sequence(:name) { |i| "name #{i}" }
    sequence(:slug) { |i| "slug_#{i}" }
  end
end
