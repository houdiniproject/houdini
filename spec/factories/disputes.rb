# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :dispute do
    stripe_dispute_id { "dp_05RsQX2eZvKYlo2C0FRTGSSA" } # the default dispute
    trait :autocreate_dispute do
      sequence(:stripe_dispute_id, "a") { |i| "dp_05RsQX2eZvKYlo2C0FRTGSS" + i }
    end
  end
end
